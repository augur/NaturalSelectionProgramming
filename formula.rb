#!/usr/bin/env ruby
# encoding: utf-8

class Formula
  attr_reader :value
  attr_accessor :variables
  
  def string_view
    nil
  end
  
  #Partial solution of formula reduction
  def cut
    self
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
    left_value.variables = vars
    right_value.variables = vars
  end
  
  def cut
    @left_value = left_value.cut
    @right_value = right_value.cut
    if @left_value.is_a? Constant and right_value.is_a? Constant
      if @left_value.is_a? IntConstant and right_value.is_a? IntConstant
        IntConstant.new value
      else
        FloatConstant.new value
      end
    else
      self
    end
  end
  

  def string_view
    '( ' + left_value.string_view + ' ' + sign + ' ' + right_value.string_view + ' )'
  end
end

class AdditionOperator < BinaryOperator
  def sign
    '+'
  end
  
  def value
    @left_value.value + @right_value.value
  end
end

class SubtractionOperator < BinaryOperator
  def sign
    '-'
  end

  def value
    @left_value.value - @right_value.value
  end
end

class MultiplicationOperator < BinaryOperator
  def sign
    '*'
  end

  def value
    @left_value.value * @right_value.value
  end
end

class DivisionOperator < BinaryOperator
  def sign
    '/'
  end

  def value
    @left_value.value / @right_value.value
  end
end







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








if __FILE__ == $0
  m1 = multip((v :x),(fc 2))
  m2 = fc 1.5
  f = minus m1, m2
  puts f.string_view #x*2 - 1.5
  f.variables = {:x => 3}
  puts f.value       #4.5
end
