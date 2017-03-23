# frozen_string_literal: true
module ActiveHal
  class Link
    attr_reader :rel

    def initialize(rel, attributes)
      @rel = rel
      @attributes = attributes
    end

    def href
      @attributes[:href]
    end

    def as_json
      @attributes.dup
    end
  end
end
