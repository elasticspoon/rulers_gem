module Rulers
  class Application
    def get_controller_and_action(env)
      _, controller_category, action, after = env['PATH_INFO'].split('/', 4)
      controller_category.capitalize!
      controller_name = "#{controller_category}Controller"

      [Object.const_get(controller_name), action]
    end
  end
end
