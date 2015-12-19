#!/usr/bin/env ruby
# encoding: utf-8


class Formula
  attr_reader :value
  attr_accessor :variables
  
  def string_view
    nil
  end
  
  #Try to reduct formula
  def cut
    self
  end
  
  def price
    FORMULA_CLASSES_PRICE[self.class]
  end
  
  #debug purpose
  def validate_vars
    not @variables.nil?
  end
end

class Constant < Formula
  def initialize(const)
    @value = const
  end
end

class IntConstant < Constant
  def string_view
    "%d" % value
  end
end

class FloatConstant < Constant
  def string_view
    "%f" % value
  end
end

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
    if @left_value.is_a? Constant and @right_value.is_a? Constant
      if @left_value.is_a? IntConstant and @right_value.is_a? IntConstant
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






if __FILE__ == $0
  m1 = multip((v :x),(fc 2))
  m2 = fc 1.5
  f = minus m1, m2
  puts f.string_view #x*2 - 1.5
  f.variables = {:x => 3}
  puts f.value       #4.5
  puts f.price       #36
end
