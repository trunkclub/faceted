module Faceted

  module Interface

    include Faceted::HasObject

    # Class methods ===========================================================

    def self.included(base)
      base.extend ActiveModel::Naming
      base.extend ClassMethods
      base.extend Faceted::Model::ModelClassMethods
      base.send(:attr_accessor, :id)
      base.send(:attr_accessor, :errors)
    end

    module ClassMethods

      def klass
        @wraps
      end

      def wraps(name, args={})
        class_name = args[:class_name] || name.to_s.classify
        @wraps = eval(class_name)
        define_method :"#{class_name.downcase}" do
          object
        end
      end

      def where(args)
        materialize(klass.where(args))
      end

    end

  end

end
