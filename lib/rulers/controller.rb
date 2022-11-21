require 'erubis'
require 'rulers/file_model'

module Rulers
  class Controller
    include Rulers::Model

    attr_reader :env

    def initialize(env)
      @env = env
      @routing_params = {}
    end

    def dispatch_other(action, routing_params={})
      puts "Dispatching #{action}"
      @routing_params = routing_params
      text = send(action)
      if get_response
        status, headers, response = get_response.to_a
        [status, headers, [response].flatten]
      else
        [200, { 'Content-Type' => 'text/html' }, [text].flatten]
      end
    end

    def dispatch(action, routing_params={})
      @routing_params = routing_params
      begin
        send(action)
      rescue RuntimeError # might not be needed with the controller mapping with Rack
        return [500, { 'content-type' => 'text/html' }, ['An error was raised']]
      end
      controller_response = get_response
      if controller_response
        status, headers, response = controller_response.to_a
        [status, headers, [response].flatten]
      else
        status, headers, response = render_response(action).to_a
      end
      [status, headers, [response].flatten]
    end

    def self.action(action, response={})
      puts "Action: #{action}"
      puts "Response: #{response}"
      proc { |env| new(env).dispatch(action, response) }
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
      puts "response: #{@response}"
      @response
    end

    def render_response(*args)
      puts "render_response: #{args}"
      response(render(*args))
    end

    def params
      old_params = request.params
      puts "old_params: #{old_params}"
      puts "routing_params: #{@routing_params}"
      params = request.params.merge(@routing_params)
      puts "params: #{params}"
      params
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
