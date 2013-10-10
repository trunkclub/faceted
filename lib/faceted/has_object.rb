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
      self.excludes = args.delete('excludes') || args.delete(:excludes)
      unless args.empty?
        self.id = args[:id]
        args.symbolize_keys.delete_if{|k,v| v.nil?}.each{|k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") && ! v.nil? }
        initialize_with_object
        args.symbolize_keys.delete_if{|k,v| v.nil?}.each{|k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") && ! v.nil? }
      end
      self.errors = []
      self.success = true
    end

    def delete
      self.success = object.delete
    end

    def excludes=(value)
      @excludes = value.nil? ? [] : value.map(&:to_sym)
    end

    def excludes
      @excludes ||= []
    end

    def reinitialize_with_object(obj)
      obj.reload
      schema_fields.each{ |k| self.send("#{k}=", obj.send(k)) if obj.respond_to?(k) && self.send(:settable_field?, k) }
    end

    def save
      return false unless schema_fields.present?
      schema_fields.each{ |k| self.send(:object).send("#{k}=", self.send(k)) if self.send(:settable_field?, k) }
      self.success = object.save
      self.errors = object.errors && object.errors.full_messages
      self.reinitialize_with_object(object) if self.success
      self.success
    end

    def schema_fields
      self.class.fields - self.excludes - [:excludes]
    end

    def to_hash
      schema_fields.inject({}) {|h,k| h[k] = self.send(k) if self.respond_to?(k); h}
    end

    private

    def initialize_with_object
      return unless object
      schema_fields.each{|k| self.send("#{k}=", object.send(k)) if object.respond_to?(k) && self.respond_to?("#{k}=") }
    end

    def object
      return unless self.class.klass
      if self.send(find_by).present?
        @object ||= self.class.klass.where(find_by => self.send(find_by)).first
      else
        @object ||= self.class.klass.new
      end
    end

    def object=(obj)
      @object = obj
      self.id = obj.id if obj.id.present?
    end

    def settable_field?(field_name)
      self.respond_to?("#{field_name}=") && object.respond_to?("#{field_name}=")
    end

  end

end

