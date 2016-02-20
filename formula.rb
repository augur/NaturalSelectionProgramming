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
  
  def to_s
    "%d" % value
  end
end


class FloatConstant < Constant
  def initialize(float_const)
    @value = Float(float_const)
    raise ArgumentError.new "Incorrect value" unless @value.finite?
  end
  
  def to_s
    "%.3f" % value
  end
end


class Variable < Formula
  def initialize(name)
    raise ArgumentError.new "Name must be symbol" unless name.class == Symbol
    @name = name
  end

  def value(variables = nil)
    raise ArgumentError.new "Variable name not found" unless variables.has_key?(@name)
    variables[@name]
  end

  def to_s
    @name.to_s
  end
end
 

class BinaryOperator < Formula
  attr_reader :operand1
  attr_reader :operand2
  
  def initialize(operand1, operand2)
    raise "Abstract class construction" if self.instance_of? BinaryOperator
    raise ArgumentError.new "Operands must be Formula type" unless
    operand1.is_a?(Formula) && operand2.is_a?(Formula)
    @operand1 = operand1
    @operand2 = operand2
  end

  def cut
    new_op1 = @operand1.cut
    new_op2 = @operand2.cut

    kind1 = operand_kind(new_op1)
    kind2 = operand_kind(new_op2)

    #stub
    if (kind1 == :const) && (kind2 == :const)
      #return cut_to_const(new_op1, new_op2)
      return nil
    elsif (kind1 == :f_const) && (kind2 == :const)
      return nil
    elsif (kind1 == :const) && (kind2 == :f_const)
      return nil
    elsif (kind1 == :f_const) && (kind2 == :f_const)
      return nil
    else
      return self.class.new(new_op1, new_op2)
    end
  end
  
  def price
    FORMULA_CLASSES_PRICE[self.class] + @operand1.price + @operand2.price     
  end

  def to_s
    "(#{@operand1}" + BINARY_OPERATORS_SIGN[self.class] + "#{@operand2})"
  end

  def value(variables = nil)
    self.class.operate(@operand1, @operand2)
  end

  private

=begin Will migrate to formula_cut.rb
  #Both arguments are meant to be Constants
  def cut_to_const(c1, c2)
    #if both are Int, then Int, otherwise Float
    if (c1.is_a?(IntConstant)&&c2.is_a?(IntConstant))
      return IntConstant.new operate(c1, c2)
    else
      return FloatConstant.new operate(c1, c2)
    end
  end
=end

  def operand_kind(op)
    return :const if op.is_a?(Constant)
    return :f_const if op.is_a?(BinaryOperator) && (op.operand1.is_a?(Constant)||op.operand2.is_a?(Constant))
    return :unkind    
  end


end


class AdditionOperator < BinaryOperator
  def self.commutative?
    true
  end 

  def self.operate(op1, op2, vars = nil)
    op1.value(vars) + op2.value(vars)
  end

  def self.combines_with(other_class)
    self == other_class or other_class == SubtractionOperator
  end
end


class SubtractionOperator < BinaryOperator
  def self.commutative?
    false
  end 

  def self.operate(op1, op2, vars = nil)
    op1.value(vars) - op2.value(vars)
  end

  def self.combines_with(other_class)
    self == other_class or other_class == AdditionOperator
  end

  #only exists for non-commutative classes
  def self.inverse_operator
    AdditionOperator
  end
end


### Refactored up to this ###
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

