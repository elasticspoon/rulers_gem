# frozen_string_literal: true

require_relative 'rulers/version'
require 'rulers/array'

module Rulers
  class Application
    def call(_env)
      `echo debug > debug.txt`
      [200, { 'content-type' => 'text/html' },
       ['Hello from Ruby on Rulers!']]
    end
  end
end
