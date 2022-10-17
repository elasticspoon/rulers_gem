# rubocop:disable Metrics/MethodLength
# frozen_string_literal: true

require_relative 'rulers/version'
require 'rulers/routing'
require 'rulers/dependencies'
require 'rulers/util'
require 'rulers/controller'

# require "rulers/array"

module Rulers
  class Application
    def call(env)
      case env['PATH_INFO']
      when '/favicon.ico'
        return [404, { 'content-type' => 'text/html' }, []]
      when '/'
        #   act = :a_quote
        #   klass = QuotesController
        # return [200, { 'content-type' => 'text/html' }, [File.read('public/index.html')]]
        # act = :index
        # klass = HomeController
        return [302, { 'Location' => '/home/index' }, []]
      else
        klass, act = get_controller_and_action(env)
      end

      controller = klass.new(env)
      begin
        text = controller.send(act)
      rescue RuntimeError
        return [500, { 'content-type' => 'text/html' }, ['An error was raised']]
      end
      [
        200,
        { 'content-type' => 'text/html' },
        [text]
      ]
    end
  end
end
# rubocop:enable Metrics/MethodLength
