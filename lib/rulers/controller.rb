require 'erubis'
require 'rulers/file_model'

module Rulers
  class Controller
    include Rulers::Model

    attr_reader :env

    def initialize(env)
      @env = env
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def response(text, status=200, headers={ 'content-type' => 'text/html' })
      raise 'Already responded!' if @response

      response_text = [text].flatten
      @response = Rack::Response.new(response_text, status, headers)
    end

    def get_response
      @response
    end

    def render_response(*args)
      response(render(*args))
    end

    def params
      request.params
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
