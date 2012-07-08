require "time"
require "date"
require "bigdecimal"

class Scrivener
  # Provides a way to define attributes so they are cast into a corresponding
  # type (defaults to +String+) when getting the attributes.
  #
  # Any object that supports a .call method can be used as a "type". The
  # following are implemented out of the box:
  #
  # - Types::Symbol
  # - Types::String
  # - Types::Integer
  # - Types::Float
  # - Types::Decimal
  # - Types::Date
  # - Types::Time
  # - Types::DateTime
  # - Types::Boolean
  #
  # @example
  #
  #   class CreateProduct < Scrivener
  #     attribute :name
  #     attribute :description
  #     attribute :price,           Decimal
  #     attribute :avaliable_after, Date
  #     attribute :stock,           Integer
  #   end
  #
  #   p = CreateProduct.new(name: "Foo", price: "10.0", available_after: "2012-07-10")
  #   p.cleaned_price #=> BigDecimal.new("10.0")
  #   p.cleaned_available_after #=> Date.new(2012, 7, 10)
  #   p.cleaned_name #=> "Foo"
  #
  module Types
    Symbol   = ->(value) { value.to_sym }
    String   = ->(value) { value.to_s }
    Integer  = ->(value) { Integer(value) }
    Float    = ->(value) { Float(value) }
    Decimal  = ->(value) { BigDecimal(value) }
    Date     = ->(value) { ::Date.parse(value) }
    DateTime = ->(value) { ::DateTime.parse(value) }
    Time     = ->(value) { ::Time.parse(value) }
    Boolean  = ->(value) {
      case value
      when "f", "false", "0"; false
      when "t", "true", "1"; true
      else !!value
      end
    }

    # Define an attribute with its corresponding type. This is similar to
    # attr_accessor, except the reader method will cast the object into the
    # proper type.
    #
    # If the casting results in a TypeError or ArgumentError, then an error on
    # :typecast will be added to this attribute and the raw attribute will be
    # returned instead.
    #
    # @example
    #
    #   attribute :foo
    #   attribute :foo, String
    #   attribute :foo, Date
    #
    def attribute(name, type=String)
      attr_writer name

      define_method name do
        begin
          val = instance_variable_get(:"@#{name}")
          val && type.call(val)
        rescue TypeError, ArgumentError
          errors[name].push(:typecast)
          val
        end
      end
    end
  end
end
