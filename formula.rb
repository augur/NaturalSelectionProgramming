#!/usr/bin/env ruby
# encoding: utf-8





#Abstract base class. Don't try to create it.
class Formula
  def initialize
    raise "Abstract class construction"
  end
  
  def value(variables = nil)
    @value
  end
  
  def string_view
    @string_view
  end
  
  def cut
    self
  end
  
  def price
    FORMULA_CLASSES_PRICE[self.class]
  end
end

class Constant < Formula
  def initialize
    super
  end
end

class IntConstant < Constant
  def initialize(int_const)
    @value = Integer(int_const)
  end
  
  def string_view
    "%d" % value
  end
end

class FloatConstant < Constant
  def initialize(float_const)
    @value = Float(float_const)
  end
  
  def string_view
    "%.3f" % value
  end
end
### Refactored up to this ### 
class Variable < Formula
  attr_reader :name
  def initialize(name)
    @name = name
  end

  def value
    variables[name]
  end

  def string_view
    name.to_s
  end
end
    
class BinaryOperator < Formula
  attr_reader :left_value
  attr_reader :right_value
  
  def initialize(left_value, right_value)
    @left_value = left_value
    @right_value = right_value
  end

  def variables= vars
    @variables = vars
    @left_value.variables = vars
    @right_value.variables = vars
  end
  
  def cut
    @left_value = @left_value.cut
    @right_value = @right_value.cut
    local_value = value
    if @left_value.is_a? Constant and @right_value.is_a? Constant
      if @left_value.is_a? IntConstant and @right_value.is_a? IntConstant and local_value.respond_to?(:infinite?) and (not local_value.infinite?)
        IntConstant.new value
      else
        FloatConstant.new value
      end
    else
      self
    end
  end
  
  def price
    FORMULA_CLASSES_PRICE[self.class] + @left_value.price + @right_value.price     
  end

  def string_view
    '( ' + left_value.string_view + ' ' + BINARY_OPERATORS_SIGN[self.class] + ' ' + right_value.string_view + ' )'
  end
  
  def validate_vars
    (not @variables.nil?) and @left_value.validate_vars and @right_value.validate_vars
  end
end

class AdditionOperator < BinaryOperator
  def value
    @left_value.value + @right_value.value
  end
end

class SubtractionOperator < BinaryOperator
  def value
    @left_value.value - @right_value.value
  end
end

class MultiplicationOperator < BinaryOperator
  def value
    @left_value.value * @right_value.value
  end
end

class DivisionOperator < BinaryOperator
  def value
    divider = @right_value.value
    return Float::INFINITY if divider == 0
    return @left_value.value / divider
  end
end

class PowerOperator < BinaryOperator
  def sign
    '**'
  end
  
  def value
    base = @left_value.value
    pow = @right_value.value
    
    if base == 0 and pow < 0
      return Float::INFINITY
    end
    if pow.abs > 100 #stop with too big powers
      return Float::INFINITY
    end
    
    result = base ** pow
    if result.is_a? Complex
      return result.real
    end
      return result
  end
end


BINARY_OPERATORS = [AdditionOperator, SubtractionOperator, MultiplicationOperator, DivisionOperator, PowerOperator]

BINARY_OPERATORS_SIGN  = {AdditionOperator       => '+',
                          SubtractionOperator    => '-',
                          MultiplicationOperator => '*',
                          DivisionOperator       => '/',
                          PowerOperator          => '**'}

FORMULA_CLASSES_PRICE =  {IntConstant            => 1,
                          FloatConstant          => 3,
                          Variable               => 5,
                          AdditionOperator       => 10,
                          SubtractionOperator    => 10,
                          MultiplicationOperator => 15,
                          DivisionOperator       => 15,
                          PowerOperator          => 30}



#Constructors shortcuts
def ic val
  IntConstant.new val
end

def fc val
  FloatConstant.new val
end

def v name
  Variable.new name
end

def plus(v1, v2)
  AdditionOperator.new v1, v2
end

def minus v1, v2
  SubtractionOperator.new v1, v2
end

def multip v1, v2
  MultiplicationOperator.new v1, v2
end

def div v1, v2
  DivisionOperator.new v1, v2
end

def pow v1, v2
  PowerOperator.new v1, v2
end

