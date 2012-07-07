require "time"
require "date"
require "bigdecimal"

class Scrivener
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

  # Provides a way to define attributes so they are cast into a corresponding
  # type (defaults to +String+) when getting the attributes.
  #
  # Any object that supports a .call method can be used as a "type". The
  # following are implemented out of the box:
  #
  # - Symbol
  # - String
  # - Integer
  # - Float
  # - Decimal
  # - Date
  # - Time
  # - DateTime
  # - Boolean
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
    # Define an attribute with its corresponding type. This creates three
    # methods:
    #
    # - A reader
    # - A writer
    # - A "cleaned" reader, that returns the value cast into the appropriate
    #   type.
    #
    # @example
    #
    #   attribute :foo
    #   attribute :foo, String
    #   attribute :foo, Date
    #
    def attribute(name, type=String)
      attr_accessor name

      define_method :"cleaned_#{name}" do
        type.call(send(name))
      end
    end
  end
end
