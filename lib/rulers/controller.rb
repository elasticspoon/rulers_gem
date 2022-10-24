require 'erubis'
require 'rulers/file_model'

module Rulers
  class Controller
    include Rulers::Model

    attr_reader :env

    def initialize(env)
      @env = env
    end

    def render(view_name, locals={})
      filename = File.join 'app', 'views', controller_name, "#{view_name}.html.erb"
      template = File.read filename
      eruby = Erubis::Eruby.new(template)
      eruby.result locals.merge(env:).merge(instance_vars)
    end

    def controller_name
      klass = self.class
      klass = klass.to_s.gsub(/Controller$/, '')
      Rulers.to_underscore klass
    end

    private

    def instance_vars
      instance_variables.inject({}) do |hash, var|
        hash.merge({ var => instance_variable_get(var) })
      end
    end
  end
end
