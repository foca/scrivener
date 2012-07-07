require "time"
require "date"
require "bigdecimal"

class Scrivener
  module Symbol # :nodoc:
    def self.parse(value)
      value.to_sym
    end
  end

  module String # :nodoc:
    def self.parse(value)
      String(value)
    end
  end

  module Fixnum # :nodoc:
    def self.parse(value)
      Integer(value)
    end
  end

  module Float # :nodoc:
    def self.parse(value)
      Float(value)
    end
  end

  module BigDecimal # :nodoc:
    def self.parse(value)
      BigDecimal(value)
    end
  end

  # Provides a way to define attributes so they are cast into a corresponding
  # type (defaults to +String+) when getting the attributes.
  #
  # Any class that supports a .parse method can be used to convert objects into
  # the corresponding types. By default these objects from ruby core/stdlib are
  # supported:
  #
  # - Symbol
  # - String
  # - Fixnum
  # - Float
  # - BigDecimal
  # - Time
  # - Date
  # - DateTime
  #
  # @example
  #
  #   class CreateProduct < Scrivener
  #     attribute :name
  #     attribute :description
  #     attribute :price,           BigDecimal
  #     attribute :avaliable_after, Date
  #     attribute :stock,           Fixnum
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
        type.parse(send(name))
      end
    end
  end
end
