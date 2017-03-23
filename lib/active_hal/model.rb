# frozen_string_literal: true
require 'active_model'
require 'active_model'
require 'active_support'
require 'active_support/hash_with_indifferent_access'
require 'hashie/mash'
require 'faraday'
require 'faraday_middleware'
require 'typhoeus/adapters/faraday'
require 'active_hal/curies'
require 'active_hal/errors'
require 'active_hal/link'

module ActiveHal
  module Model
    extend ActiveSupport::Concern
    include ActiveModel::Model
    include ActiveModel::Dirty

    class_methods do
      def hal_attr_reader(*names)
        names.each do |name|
          define_method name do
            read_attribute(name)
          end
        end
      end

      def hal_attr_writer(*names)
        names.each do |name|
          define_method :"#{name}=" do |value|
            write_attribute(name, value)
          end
          define_attribute_methods name
        end
      end

      def hal_attr(*names)
        hal_attr_reader(*names)
        hal_attr_writer(*names)
      end

      def belongs_to(name, **options)
        define_method name do
          single_relation(name, options).load
        end
      end

      def has_many(name, **options)
        define_method name do
          multi_relation(name, options).map(&:load)
        end
      end
    end

    def initialize(attributes)
      super(attributes)
      changes_applied
    end

    def read_attribute(name)
      attributes[name.to_sym]
    end

    def write_attribute(name, value)
      raise 'Cannot assign reserved attributes' if name.to_s.start_with?('_')
      public_send(:"#{name}_will_change!") if respond_to?(:"#{name}_will_change!")
      attributes[name.to_sym] = value
    end

    def assign_attributes(new_attributes)
      new_attributes.each_pair do |name, value|
        case name.to_sym
        when :_links then set_links(value)
        when :_embedded then set_embedded(value)
        else write_attribute(name, value)
        end
      end
    end

    def persisted?
      links[:self].present?
    end

    def loaded?
      attributes.any?
    end

    def load
      reload unless loaded?
      self
    end

    def reload
      response = connection.get(links[:self].href)
      assign_attributes(response.body)
      self
    end

    def as_link
      links[:self].as_json
    end

    def as_json
      json = { _links: links.to_hash(symbolize_keys: true) }
      json[:_embedded] = embedded.to_hash(symbolize_keys: true) if embedded.any?
      json.merge!(attributes)
      json
    end

    def save
      return false unless valid?
      return true unless changed?

      response = connection.patch(links[:self].href, to_json)
      unless response.success?
        raise ModelNotSaved.new("Model not saved; status #{response.status}", self)
      end

      changes_applied
      true
    end

    def save!
      raise ModelInvalid, self unless save
    end

    private

    def attributes
      @attributes ||= {}
    end

    def links
      @links ||= set_links({})
    end

    def set_links(links)
      @curies = Curies.new(links.delete('curies'))
      expanded = links.map { |rel, attrs| [@curies.expand(rel), Link.new(rel, attrs)] }.to_h
      @links = ActiveSupport::HashWithIndifferentAccess.new(expanded)
    end

    def embedded
      @embedded ||= set_embedded({})
    end

    def set_embedded(embedded)
      @embedded = Hashie::Mash.new(embedded)
    end

    def single_relation(name, options)
      rel = options.fetch(:rel, name)
      class_name = options.fetch(:class_name, name.to_s.classify).constantize

      if links.key?(rel)
        class_name.new(_links: { self: links[rel].as_json })
      elsif embedded.key?(rel)
        class_name.new(embedded[rel])
      elsif !options.fetch(:optional, false)
        raise "#{rel} not found"
      end
    end

    def multi_relation(name, options)
      rel = options.fetch(:rel, name)
      class_name = options.fetch(:class_name, name.to_s.classify).constantize

      if links.key?(rel)
        links[rel].map { |link| class_name.new(_links: { self: link.as_json }) }
      elsif embedded.key?(rel)
        embedded[rel].map { |data| class_name.new(data) }
      else
        []
      end
    end

    def connection
      @connection ||= Faraday.new.tap do |conn|
        conn.adapter :typhoeus
        conn.request :json
        conn.response :json, content_type: 'application/json'
        conn.options.open_timeout = ENV.fetch('HAL_MODEL_OPEN_TIMEOUT', 1).to_i
        conn.options.timeout = ENV.fetch('HAL_MODEL_FETCH_TIMEOUT', 1).to_i
      end
    end
  end
end
