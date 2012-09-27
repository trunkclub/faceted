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
        @collects = eval "#{scope}#{args[:class_name] || name.to_s.classify}"
        define_method :"#{name.downcase}" do
          objects
        end
        define_method :finder do
          {"#{args[:find_by]}" => self.send(args[:find_by])}
        end
        self.send(:attr_accessor, args[:find_by])
      end

      def collected_class
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

    def objects
      return unless self.class.collected_class
      @objects ||= self.class.collected_class.where(self.finder)
    end

  end

end