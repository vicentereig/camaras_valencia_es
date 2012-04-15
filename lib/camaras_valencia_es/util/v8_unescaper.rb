require 'v8'

module CamarasValenciaEs
  module Util
    module V8Unescaper
      extend ActiveSupport::Concern

      module ClassMethods
        def unescape(string)
          unescape_helper string
        end

        protected
          def unescape_helper(string)
            @ctx ||= V8::Context.new
            @ctx.eval(js_unescape(string))
          end

          def js_unescape(string)
            "unescape('#{string}')"
          end
      end

      def unescape(string)
        self.class.unescape string
      end
    end
  end
end