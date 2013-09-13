module Faceted

  module Model

    require 'json'
    require 'active_support/core_ext/hash'

    # Class methods ============================================================

    module ModelClassMethods

      def build_association_from(field)
        bare_name = field.gsub(/_id$/, '')
        if field =~ /_id$/
          klass = eval "#{scope}#{bare_name.classify}"
          fields << bare_name.to_sym
          define_method :"#{bare_name}" do
            klass.new(:id => self.send(field))
          end
        end
      end

      def create(params={})
        obj = self.new(params)
        obj.save
        obj
      end

      def field(name, args={})
        fields << name
        define_method :"#{name}" do
          val = instance_variable_get("@#{name}")
          val.nil? ? args[:default] : val
        end
        unless args[:read_only]
          define_method :"#{name}=" do |val|
            instance_variable_set("@#{name}", val)
          end
        end
        build_association_from(name.to_s) if name.to_s.include?("id") && ! args[:skip_association]
      end

      def fields
        @fields ||= [:id, :excludes]
      end

      def materialize(objects=[], args={})
        objects.compact.inject([]) do |a, object|
          interface = self.new(args)
          interface.send(:object=, object)
          interface.send(:initialize_with_object)
          a << interface
        end
      end

      def scope
        parent.to_s == "Object" ? "::" : "#{parent.to_s}::"
      end

    end

  end

end
