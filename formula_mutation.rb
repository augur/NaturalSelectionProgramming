#!/usr/bin/env ruby
# encoding: utf-8

module FormulaMutator

  #Before first call of "mutate" mixin method, one should set list of possible variables
  #mutations (array of symbols, like [:x, :y, :z])
  def self.vars_list=(vars)
    @vars_list = vars
  end

  def self.vars_list
    @vars_list 
  end

  #returns new Formula, based on random mutation
  def mutate
    if self.is_a?(BinaryOperator)
      return FormulaMutator::bop_mutate(self) 
    else
      return FormulaMutator::random_mutation(self)
    end
  end

  def self.bop_mutate(f)
    case BOP_ACTION.sample
    when :left
      return f.class.new(f.operand1.mutate, f.operand2)
    when :right
      return f.class.new(f.operand1, f.operand2.mutate)
    when :self
      return random_mutation(f)
    else
      raise "Unreachable case"
    end
  end

  def self.random_mutation(f)
    case ACTIONS.sample
    when :grow
      return grow(f)
    when :shrink
      return shrink(f)
    when :shift
      return shift(f)
    else
      raise "Unreachable case"
    end
  end

  def self.grow(f)
    case f
    when Formula::Constant
      return grow_constant(f)
    when Formula::Variable
      return grow_variable(f)
    when Formula::BinaryOperator
      return grow_bop(f)
    else
      raise "Unreachable case"
    end
  end

  def self.shrink(f)
    case f
    when Formula::Constant
      return shrink_constant(f)
    when Formula::Variable
      return shrink_variable(f)
    when Formula::BinaryOperator
      return shrink_bop(f)
    else
      raise "Unreachable case"
    end
  end

  def self.shift(f)
    case f
    when Formula::Constant
      return shift_constant(f)
    when Formula::Variable
      return shift_variable(f)
    when Formula::BinaryOperator
      return shift_bop(f)
    else
      raise "Unreachable case"
    end
  end

  ### "grow" methods ###
  def self.grow_constant(c)
  end

  def self.grow_variable(v)
  end

  def self.grow_bop(bop)
  end

  ### "shrink" methods ###
  def self.shrink_constant(c)
  end

  def self.shrink_variable(v)
  end

  def self.shrink_bop(bop)
  end

  ### "shift" methods ###
  def self.shift_constant(c)
  end

  def self.shift_variable(v)
  end

  def self.shift_bop(bop)
  end


  ### Mutation Coefficients ###
  ACTIONS = [:grow, :shrink, :shift]
  #40% mutation affects left operand, same for right, 20% it affect operator itself
  BOP_ACTION = [:left, :left, :right, :right, :self]
end

### Refactored up to this ###
=begin
#=== Mutation Probability Constants ===

#Dice rolls 0..9
FORMULA_GROW = 0..1 
FORMULA_SHRINK = 2..4
FORMULA_SHIFT = 5..8
FORMULA_CUT = 9

ACTIONS = [:grow, :shrink, :shift, :cut]

#Dice rolls 0..3
CONSTANT_TO_BINARY_OPERATOR = 0..1
CONSTANT_TO_VARIABLE = 2..3

#Chance that Constants change their type
INT_TO_FLOAT = 0.1
FLOAT_TO_INT = 0.1

#Chance Binary Operator affect self rather than one of its values
BOP_AFFECT_SELF = 0.15

#Dice rolls 0..3
BOP_SWAP = 0..1
BOP_CHANGE_TYPE = 2..3

INT_CONSTANTS = [-1, -2, 1, 2]

#Chance that variable will be used
NEW_VARIABLE = 0.2

ALLOWED_BINARY_OPERATORS = [AdditionOperator, SubtractionOperator, MultiplicationOperator, DivisionOperator]#, PowerOperator]


def mutate_Formula(f, action = nil)
  
  f.variables = f.variables
  unless f.validate_vars
    puts "input failed"
    puts f.inspect
    puts f.string_view
    exit
  end
  
  action = random_action if action.nil?

  if action == :cut
    result = f.cut
  else
    if f.is_a? Constant
      result = mutate_Constant f, action
    elsif f.is_a? Variable
      result = mutate_Variable f, action
    elsif f.is_a? BinaryOperator
      result = mutate_BinaryOperator f, action
    else
      raise
    end
  end
  
  result.variables = f.variables
  
  unless result.validate_vars
    puts "output failed"
    puts result.inspect
    puts result.string_view
    exit
  end

  return result
end

def mutate_Variable(v, action)
  case action
  when :grow
    random_BinaryOperator(v)  
  when :shrink
    random_Constant
  when :shift
    random_Variable(v.variables)
  end
end

def mutate_Constant(c, action)
  case action
  when :grow
    case rand 0..3
    when CONSTANT_TO_BINARY_OPERATOR
      random_BinaryOperator(c)
    when CONSTANT_TO_VARIABLE
      random_Variable(c.variables)
    end
  when :shrink
    #unable to shrink constant
    c
  when :shift
    if c.is_a? IntConstant
      mutate_IntConstant c
    elsif c.is_a? FloatConstant
      mutate_FloatConstant c
    else
      raise
    end
  end
end


def mutate_BinaryOperator(bo, action)
  left_value = bo.left_value
  right_value = bo.right_value
  
  affect_self = BOP_AFFECT_SELF > rand
  #puts affect_self
  if (affect_self)
    case action
    when :grow
      random_BinaryOperator(bo)
    when :shrink
      [left_value, right_value].sample      
    when :shift
      case rand 0..3
      when BOP_SWAP
        bo.class.new(right_value, left_value)
      when BOP_CHANGE_TYPE
        random_BinaryOperator(left_value, right_value)
      end
    end
  else
    if rand > 0.5
      left_value = mutate_Formula(left_value, action)
    else
      right_value = mutate_Formula(right_value, action)
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
  if FLOAT_TO_INT > rand and (not fc.value.infinite?)
    IntConstant.new fc.value.round
  else
    FloatConstant.new(fc.value + random_Float)    
  end
end

#=== utilitary funcs ===

def random_action()
  dice = rand 0..9
  case dice
  when FORMULA_GROW
    :grow
  when FORMULA_SHRINK
    :shrink
  when FORMULA_SHIFT
    :shift
  when FORMULA_CUT
    :cut
  end
end

def random_BinaryOperator(value, value2 = nil)
  left_value = value
  right_value = value2.nil? ? random_Value(value.variables) : value2
  if rand > 0.5 #swap
    left_value, right_value = right_value, left_value
  end 
  ALLOWED_BINARY_OPERATORS.sample.new(left_value, right_value)
end


def random_Value(vars)
  if NEW_VARIABLE > rand
    random_Variable(vars)
  else 
    random_Constant
  end
end

def random_Variable(vars)
  Variable.new(vars.keys.sample)
end

def random_Constant
 if rand > 0.5
   IntConstant.new INT_CONSTANTS.sample
 else
   FloatConstant.new(random_Float)
 end
end

# -2 .. 2
def random_Float()
  rand * 4 - 2
end

=end
