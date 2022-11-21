class RouteObject
  def initialize
    @rules = []
    @defaults = []
  end

  def match(url, *args)
    options = {}
    options = args.pop if args[-1].is_a?(Hash)
    options[:default] ||= {}

    dest = nil
    dest = args.pop unless args.empty?
    raise 'Too many args!' unless args.empty?

    vars = []
    regexp = build_regex(url, vars)
    puts "Adding route: #{regexp}"
    @rules.push({ regexp: Regexp.new("^/#{regexp}$"), vars:, dest:, options: })
  end

  def set_regexps(url, vars)
    parts = url.split('/').reject(&:empty?)

    parts.map do |part|
      parse_action(part, vars)
    end.join('/')
  end

  def build_regex(url, vars)
    # Example: :controller(/:action(/:id))
    # capture g1: :controller
    # capture g2: :action(/:id)
    # g2 gets marked as optional then recusively turned into regex
    if url =~ %r{^(.*?)\(/(.*)\)$}
      return set_regexps(::Regexp.last_match(1), vars) +
             make_optional(build_regex(::Regexp.last_match(2), vars))
    end

    set_regexps(url, vars)
  end

  def make_optional(url)
    "(?:/#{url})?"
  end

  def parse_action(part, vars)
    case part[0]
    when ':'
      vars << part[1..]
      '([a-zA-Z0-9_-]+)'
    when '*'
      vars << part[1..]
      '(.*)'
    else
      part
    end
  end

  def root(*args)
    match '', *args
  end

  def resources(controller)
    match "/#{controller}", default: { 'action' => 'index', 'controller' => controller }
    match "/#{controller}/:id", default: { 'action' => 'show', 'controller' => controller }
    match "/#{controller}/new", default: { 'action' => 'new', 'controller' => controller }
    match "/#{controller}/edit", default: { 'action' => 'edit', 'controller' => controller }
  end

  def check_url(url) # rubocop:disable Metrics/AbcSize
    url.chomp!('/')
    @rules.each do |rule|
      puts "Checking rule: #{rule} against #{url}"
      match = rule[:regexp].match(url)

      next unless match

      options = rule[:options]
      params = options[:default].dup

      rule[:vars].each_with_index do |var, index|
        puts "Setting #{var} to #{match.captures[index]}"
        params[var] = match.captures[index]
      end

      dest = nil
      return get_dest(rule[:dest], params) if rule[:dest]

      controller = params['controller']
      action = params['action']
      return get_dest("#{controller}##{action}", params)
    end

    nil
  end

  def get_dest(dest, routing_params={})
    puts "Getting destination: #{dest}"
    return dest if dest.respond_to?(:call)

    if dest =~ /^([^#]+)#([^#]+)$/
      name = ::Regexp.last_match(1).capitalize
      cont = Object.const_get("#{name}Controller")
      return cont.action(::Regexp.last_match(2), routing_params)
    end

    raise "No destination: #{dest.inspect}!"
  end
end

module Rulers
  class Application
    def route(&)
      puts 'Routing...'
      @route_obj ||= RouteObject.new
      @route_obj.instance_eval(&)
    end

    def get_rack_app(env)
      raise 'No routes!' unless @route_obj

      puts 'Getting rack app...'
      @route_obj.check_url(env['PATH_INFO'])
    end

    def get_controller_and_action(env)
      _, controller_category, action, after = env['PATH_INFO'].split('/', 4)
      controller_category.capitalize!
      controller_name = "#{controller_category}Controller"

      [Object.const_get(controller_name), action]
    end
  end
end
