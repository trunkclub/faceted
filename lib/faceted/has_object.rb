module Faceted

  module HasObject

    module ClassMethods

      def fields
        @fields ||= [:id]
      end

      def materialize(objects=[])
        objects.compact.inject([]) do |a, object|
          instance = self.new
          instance.send(:object=, object)
          instance.send(:initialize_with_object)
          a << instance
        end
      end

    end

    # Instance methods =======================================================

    def initialize(args={})
      self.id = args[:id]
      initialize_with_object
      ! args.empty? && args.symbolize_keys.delete_if{|k,v| v.nil?}.each{|k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") && ! v.blank? }
      self.errors = []
      self.success = true
    end

    def save
      return false unless schema_fields
      schema_fields.each{ |k| object.send("#{k}=", self.send(k)) if self.send(:settable_field?, k) }
      self.success = object.save
      self.id = object.id
      self.errors = object.errors && object.errors.full_messages
      self.success
    end

    def schema_fields
      self.class.fields
    end

    def to_hash
      schema_fields.inject({}) {|h,k| h[k] = self.send(k); h}
    end

    private

    def initialize_with_object
      return unless object
      schema_fields.each{ |k| self.send("#{k}=", object.send(k)) if self.respond_to?("#{k}=") }
    end

    def object
      return unless self.class.klass
      @object ||= self.id ? self.class.klass.find(self.id) : self.class.klass.new
    end

    def object=(obj)
      @object = obj
      self.id = obj.id
    end

    def settable_field?(field_name)
      self.respond_to?("#{field_name}=") && object.respond_to?("#{field_name}=")
    end

  end

end

