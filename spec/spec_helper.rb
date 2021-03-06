# frozen_string_literal: true
require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_hal'
require 'webmock/rspec'
require 'byebug'

WebMock.disable_net_connect!
