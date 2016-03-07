#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'formula_cut'
require_relative 'formula_mutation'

module Formula
  #Abstract base class. Don't try to create it.
  class Formula
    include FormulaMutator
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
    include BinaryOperatorCut

    attr_reader :operand1
    attr_reader :operand2
    
    def initialize(operand1, operand2)
      raise "Abstract class construction" if self.instance_of? BinaryOperator
      raise ArgumentError.new "Operands must be Formula type" unless
      operand1.is_a?(Formula) && operand2.is_a?(Formula)
      @operand1 = operand1
      @operand2 = operand2
    end

    def price
      FORMULA_CLASSES_PRICE[self.class] + @operand1.price + @operand2.price     
    end

    def to_s
      "(#{@operand1}" + BINARY_OPERATORS_SIGN[self.class] + "#{@operand2})"
    end

    def value(variables = nil)
      self.class.operate(@operand1, @operand2, variables)
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


  class MultiplicationOperator < BinaryOperator
    def self.commutative?
      true
    end

    def self.operate(op1, op2, vars = nil)
      op1.value(vars) * op2.value(vars)      
    end

    def self.combines_with(other_class)
      self == other_class or other_class == DivisionOperator
    end
  end


  class DivisionOperator < BinaryOperator
    def self.commutative?
      false
    end 

    #Able to raise ZeroDivisionError
    def self.operate(op1, op2, vars = nil)
      op1.value(vars) / op2.value(vars)
    end

    def self.combines_with(other_class)
      self == other_class or other_class == MultiplicationOperator
    end

    #only exists for non-commutative classes
    def self.inverse_operator
      MultiplicationOperator
    end
  end


  class PowerOperator < BinaryOperator
    def self.commutative?
      false
    end

    def self.operate(op1, op2, vars = nil)
      base = op1.value(vars)
      pow = op2.value(vars)
      if pow > 1024 #lets try to limit exponent power
        raise ArgumentError.new "Power exceeds limit"
      end
      result = base ** pow
      case result
      when Integer
        return result
      when Complex
        return result.real
      else
        return Float(result)
      end
    end

    def self.combines_with(other_class)
      false
    end
  end


  BINARY_OPERATORS = [AdditionOperator, SubtractionOperator,
                      MultiplicationOperator, DivisionOperator, 
                      PowerOperator]

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

end
