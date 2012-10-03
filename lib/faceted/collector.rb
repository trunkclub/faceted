module Faceted

  module Collector

    include Faceted::Model

    def self.included(base)
      base.extend ActiveModel::Naming
      base.send(:attr_accessor, :errors)
      base.send(:attr_accessor, :success)
      base.send(:attr_accessor, :fields)
      base.extend ClassMethods
      base.extend Faceted::Model::ModelClassMethods
    end

    # Class methods ===========================================================

    module ClassMethods

      def collects(name, args={})
        @fields = [name]
        find_by = args[:find_by] ? args[:find_by] : "#{name.to_s.downcase.singularize}_id"
        @collects ||= {}
        @collects[name.downcase] = eval "#{scope}#{args[:class_name] || name.to_s.classify}"
        define_method :"#{name.downcase}" do
          objects(name.downcase.to_sym)
        end
        define_method :"#{name.downcase}_finder" do
          {"#{find_by}" => self.send(find_by)}
        end
        self.send(:attr_accessor, find_by)
      end

      def collected_classes
        @collects
      end

    end

    # Instance methods =========================================================

    def initialize(args={})
      ! args.empty? && args.symbolize_keys.delete_if{|k,v| v.nil?}.each do |k,v|
        self.send("#{k}=", v) if self.respond_to?("#{k}=") && ! v.blank?
      end
      self.errors = []
      self.success = true
    end

    def to_hash
      self.class.fields.inject({}){ |h,f| h[f] = self.send(f).map{|o| o.to_hash}; h }
    end

    private

    def objects(klass)
      return [] unless self.class.collected_classes
      return [] unless self.class.collected_classes.keys.include?(klass)
      self.class.collected_classes[klass].where(self.send("#{klass.to_s}_finder"))
    end

  end

end