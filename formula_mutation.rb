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
    if self.is_a?(Formula::BinaryOperator)
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
    if rand > 0.5
      return random_variable
    else
      return random_bop_random_op(c)
    end
  end

  def self.grow_variable(v)
    random_bop_random_op(v)
  end

  def self.grow_bop(bop)
    random_bop_random_op(bop)
  end

  ### "shrink" methods ###
  def self.shrink_constant(c)
    #cannot shrink constant, shift it instead
    shift_constant(c)
  end

  def self.shrink_variable(v)
    random_constant
  end

  def self.shrink_bop(bop)
    if rand > 0.5
      bop.operand1
    else
      bop.operand2
    end
  end

  ### "shift" methods ###
  def self.shift_constant(c)
    change_type = rand > 0.5
    case c
    when Formula::IntConstant
      if change_type
        Formula::FloatConstant.new c.value
      else
        Formula::IntConstant.new c.value + random_int
      end
    when Formula::FloatConstant
      if change_type
        Formula::IntConstant.new c.value
      else
        Formula::FloatConstant.new c.value + random_float
      end
    else
      raise "Unreachable case"
    end
  end

  def self.shift_variable(v)
    random_variable
  end

  def self.shift_bop(bop)
    case BOP_SHIFT.sample
    when :swap
      return bop.class.new(bop.operand2, bop.operand1)
    when :morph
      return random_bop(bop.operand1, bop.operand2)
    when :cut
      return bop.cut
    else
      raise "Unreachable case"
    end
  end

  ### helper funcs ###

  def self.random_bop(op1, op2)
    [Formula::AdditionOperator,
     Formula::SubtractionOperator,
     Formula::MultiplicationOperator,
     Formula::DivisionOperator,
     Formula::PowerOperator].sample.new(op1, op2)
  end

  def self.random_bop_random_op(op)
    if rand > 0.5
      random_bop(op, random_operand)
    else
      random_bop(random_operand, op)
    end
  end

  def self.random_operand
    if rand > 0.5
      random_variable
    else
      random_constant
    end
  end

  def self.random_variable
    Formula::Variable.new @vars_list.sample
  end

  def self.random_constant
    if rand > 0.5
      Formula::IntConstant.new random_int
    else
      Formula::FloatConstant.new random_float
    end    
  end

  def self.random_int
    [-2, -1, 1, 2].sample
  end

  # -2..2
  def self.random_float
    rand * 4 - 2
  end

  ### Mutation Coefficients ###
  ACTIONS = [:grow, :shrink, :shift]
  #40% mutation affects left operand, same for right, 20% it affect operator itself
  BOP_ACTION = [:left, :left, :right, :right, :self]
  #40% swapping operands, 40% change operator type, 20% reduct
  BOP_SHIFT = [:swap, :swap, :morph, :morph, :cut]
end
