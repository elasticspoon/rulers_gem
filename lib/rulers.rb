# frozen_string_literal: true

require_relative 'rulers/version'
require 'rulers/routing'
# require "rulers/array"

module Rulers
  class Application
    def call(env)
      return [404, { 'content-type' => 'text/html' }, []] if env['PATH_INFO'] == '/favicon.ico'

      klass, act = get_controller_and_action(env)

      controller = klass.new(env)
      text = controller.send(act)
      [
        200,
        { 'content-type' => 'text/html' },
        [text]
      ]
    end
  end

  class Controller
    attr_reader :env

    def initialize(env)
      @env = env
    end
  end
end
