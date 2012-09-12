module Faceted

  module Presenter

    require 'json'
    require 'active_support/core_ext/hash'

    # Class methods ==========================================================

    def self.included(base)
      base.extend ActiveModel::Naming
      base.extend ClassMethods
      base.send(:attr_accessor, :id)
      base.send(:attr_accessor, :errors)
      base.send(:attr_accessor, :success)
    end

    module ClassMethods

      def build_association_from(field)
        bare_name = field.gsub(/_id$/, '')
        if field =~ /_id$/
          klass = eval "#{scope}#{bare_name.classify}"
          define_method :"#{bare_name}" do
            klass.new(:id => self.send(field))
          end
        else
          klass = eval "::#{self.presented_class}"
          define_method :"#{self.presented_class}" do
            klass.new(:id => self.send(field))
          end
        end
      end

      def field(name, args={})

        fields << name

        define_method :"#{name}" do
          instance_variable_get("@#{name}") || args[:default]
        end

        define_method :"#{name}=" do |val|
          instance_variable_set("@#{name}", val)
        end

        build_association_from(name.to_s) if name.to_s.include?("_id") && ! args[:skip_association]

      end

      def create(params={})
        object = self.new(params)
        object.save
        object
      end

      def fields
        @fields ||= []
      end

      def fields=(*args)
        fields << args
      end

      def materialize(objects=[])
        objects.compact.inject([]) do |a, object|
          presenter = self.new
          presenter.object = object
          presenter.initialize_with_object
          a << presenter
        end
      end

      def presented_class
        @presents
      end

      def presents(name, args={})
        @presents = args[:class_name] || name.to_s.classify
      end

      def scope
        parent.to_s == "Object" ? "::" : "#{parent.to_s}::"
      end

      def where(args)
        materialize(eval(presented_class).where(args))
      end

    end

    # Instance methods =======================================================

    def initialize(args={})
      self.id = args[:id]
      self.initialize_with_object
      ! args.empty? && args.symbolize_keys.delete_if{|k,v| v.nil?}.each{|k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") && ! v.blank? }
      self.errors = []
      self.success = true
    end

    def initialize_with_object
      return unless object
      object.attributes.each{ |k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") }
    end

    def object
      return unless self.class.presented_class
      @object ||= self.id ? eval(self.class.presented_class).find(self.id) : eval(self.class.presented_class).new
    end

    def object=(obj)
      @object = obj
    end

    def save
      self.class.fields.each do |k|
        self.object.send("#{k}=", self.send(k)) if self.object.respond_to?("#{k}=")
      end
      self.object.save!
    end

    def to_hash
      self.class.fields.inject({}) {|h,k| h[k] = self.send(k); h}
    end

  end

end
