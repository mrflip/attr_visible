module AttrVisible
  def self.included(base) #:nodoc:
    base.class_inheritable_accessor :serialize_defaults_options
    base.serialize_defaults_options = {}
    base.extend ClassMethods
    [:to_xml, :to_json, :to_yaml].each do |to_meth|
      base.class_eval <<-end_eval
      def #{to_meth}_with_defaults( options = {}, &block)
        options = options.reverse_merge(serialize_defaults_options)
        self.#{to_meth}_without_defaults(options, &block)
      end
      alias_method_chain :#{to_meth}, :defaults
      end_eval
    end
  end

  module ClassMethods

    def serialize_defaults serialize_options
      self.serialize_defaults_options.merge! serialize_options
    end

    # Attributes named in this macro are suggested to be non-visible to the outside world.
    #
    # Nothing currently enforces these instructions, but some helpers are provided
    # for the various serialization methods (to_xml, to_json, etc.).
    #
    #   class User < ActiveRecord::Base
    #     # has attributes id, name, email and password
    #     attr_visible :id, :name, :email
    #   end
    #
    #   user = User.new("name" => "David", "email" => "foo@bar.com", "password" => "monkey")
    #   user.to_json # {"user": { "id":1, "name":"David", "email":"foo@bar.com" } }
    #
    def attr_visible(*attributes)
      write_inheritable_attribute("attr_visible", Set.new(attributes.map(&:to_s)) + (visible_attributes || []))
      serialize_defaults_options[:only] = read_inheritable_attribute("attr_visible")
    end

    # Returns an array of all the attributes that have been made accessible, by default, for serialization
    def visible_attributes # :nodoc:
      read_inheritable_attribute("attr_visible")
    end
  end
end
