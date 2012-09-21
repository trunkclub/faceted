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
        define_method :"#{class_name.downcase}" do
          object
        end
      end

      def where(args)
        if klass.respond_to? :fields
          # Mongoid
          attrs = args.select{|k,v| klass.fields.keys.include? k.to_s}
        else
          # ActiveRecord et al
          attrs = args.select{|k,v| klass.column_names.include? k.to_s}
        end
        materialize(klass.where(attrs))
      end

    end

  end

end
