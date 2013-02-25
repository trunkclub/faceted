module Faceted

  module Presenter

    include Faceted::HasObject

    # Class methods ===========================================================

    def self.included(base)
      base.extend ActiveModel::Naming
      base.extend ClassMethods
      base.extend Faceted::Model::ModelClassMethods
      base.send(:attr_accessor, :id)
      base.send(:attr_accessor, :errors)
      base.send(:attr_accessor, :success)
    end

    module ClassMethods

      def klass
        @presents
      end

      def presents(name, args={})
        class_name = args[:class_name] || name.to_s.classify
        @presents = eval(class_name)
        define_method :find_by do
          args[:find_by] || :id
        end
        define_method :"#{class_name.downcase}" do
          object
        end
      end

      def all
        materialize(klass.all)
      end

      def find(id)
        materialize(klass.where(id: id).first)
      end

      def where(args)
        if klass.respond_to? :fields
          if klass.fields.respond_to?(:keys)
            # Mongoid
            attrs = args.select{|k,v| klass.fields.keys.include? k.to_s}
          else
            attrs = args.select{|k,v| klass.fields.include? k.to_s}
          end
        else
          # ActiveRecord et al
          attrs = args.select{|k,v| klass.column_names.include? k.to_s}
        end
        materialize(klass.where(attrs))
      end

    end

  end

end
