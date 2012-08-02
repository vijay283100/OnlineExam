require 'action_dispatch/middleware/show_exceptions'

#module ActionDispatch
#  class ShowExceptions
#    private
#      def render_exception_with_template(env, exception)
#        body = ErrorsController.action(rescue_responses[exception.class.name]).call(env)
#        log_error(exception)
#        body
#      rescue
#        render_exception_without_template(env, exception)
#      end
      
#      alias_method_chain :render_exception, :template
#  end
#end



module ActionDispatch
  class ShowExceptions
    def render_exception(env, exception)
      if exception.kind_of? ActionController::RoutingError
        render(500, 'it was routing error')
      else
        render(500, "Some problem has occured.")
      end
    end
  end
end

