module Registrar
  module Adapter
    class Params
      def initialize(app, mapping)
        @app = app
        @mapping = mapping
      end

      def call(env)
        builder = Builder.new(env, @mapping)
        builder.build_registrar_params
        builder.define_params

        @app.call(env)
      end

      private

      class Builder
        def initialize(env, mapping)
          @env = env
          @mapping = mapping
        end

        def build_registrar_params
          @mapping.each do |from, to|
            namespace_from, attr_from = from.split('#')
            value = request.params[namespace_from]

            if value.class != String && attr_from
              value = request.params[namespace_from][attr_from]
            end

            namespace_to, attr_to = to.split('#')

            if namespace_to
              if attr_to
                params[namespace_to][attr_to] = value
              else
                params[namespace_to] = value
              end
            end
          end
        end

        def define_params
          params.each do |namespace, values|
            request.update_param(namespace, values)
          end
        end

        def request
          @request ||= Rack::Request.new(@env)
        end

        def params
          @params ||= @env['registrar.params'] = Hash.new {|h,k| h[k] = {}}
        end
      end
    end
  end
end
