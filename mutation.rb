#!/usr/bin/env ruby
# encoding: utf-8
# All mutation rules for different classes are gathered here
require_relative 'formula'


#=== Mutation Probability Constants ===

#Chance that formula will just be reducted
CUT_FORMULA = 0.05

#Chance that constant becomes operator
CONSTANT_TO_BINARY_OPERATOR = 0.1

#Chance that new value will be variable, not constant
NEW_VARIABLE = 0.05

#Chance that Constants change their type
INT_TO_FLOAT = 0.1
FLOAT_TO_INT = 0.1

#Chance that operator mutate will be just swap values
OPERATOR_SWAP = 0.05

#Chance operator replaced by one of its values
OPERATOR_TO_VALUE = 0.05

OPERATOR_CHANGE_TYPE = 0.05

OPERATOR_EMBEDS = 0.05



#All availiable binary ops
BINARY_OPERATORS = [AdditionOperator, SubtractionOperator, MultiplicationOperator, DivisionOperator, PowerOperator]
INT_CONSTANTS = [-1, -2, 1, 2]



def mutate_Formula(f)
  if CUT_FORMULA > rand
    result = f.cut
  else
    if f.is_a? Constant
      result = mutate_Constant f
    elsif f.is_a? Variable
      result = mutate_Variable f
    elsif f.is_a? BinaryOperator
      result = mutate_BinaryOperator f
    else
      raise
    end
  end
  
  result.variables = f.variables
  return result
end

def mutate_Variable(v)
  random_BinaryOperator(v)
end


def mutate_Constant(c)
  if CONSTANT_TO_BINARY_OPERATOR > rand
    random_BinaryOperator(c)
  else
    if c.is_a? IntConstant
      mutate_IntConstant c
    elsif c.is_a? FloatConstant
      mutate_FloatConstant c
    else
      raise
    end
  end
end

def mutate_BinaryOperator(bo)
  left_value = bo.left_value
  right_value = bo.right_value
  if OPERATOR_TO_VALUE > rand
    [left_value, right_value].sample
  elsif OPERATOR_SWAP > rand
    bo.class.new(right_value, left_value)
  elsif OPERATOR_CHANGE_TYPE > rand
    random_BinaryOperator(left_value, right_value)
  elsif OPERATOR_EMBEDS > rand
    random_BinaryOperator(bo)
  else
    if rand > 0.5
      left_value = mutate_Formula(left_value)
    else
      right_value = mutate_Formula(right_value)
    end
    bo.class.new(left_value, right_value)
  end
end


def mutate_IntConstant(ic)
  if INT_TO_FLOAT > rand
    FloatConstant.new ic.value
  else
    IntConstant.new(ic.value + INT_CONSTANTS.sample)
  end
end

def mutate_FloatConstant(fc)
  if FLOAT_TO_INT > rand
    IntConstant.new fc.value.round
  else
    FloatConstant.new(fc.value + random_Float)    
  end
end

#=== utilitary funcs ===

def random_BinaryOperator(value, value2 = nil)
  left_value = value
  right_value = value2.nil? ? random_Value(value.variables) : value2
  if rand > 0.5 #swap
    left_value, right_value = right_value, left_value
  end 
  BINARY_OPERATORS.sample.new(left_value, right_value)
end


def random_Value(vars)
  if NEW_VARIABLE > rand
    Variable.new(vars.keys.sample)
  else #new constant
    if rand > 0.5
      IntConstant.new INT_CONSTANTS.sample
    else
      FloatConstant.new(random_Float)
    end
  end
end

# -2 .. 2
def random_Float()
  rand * 4 - 2
end


