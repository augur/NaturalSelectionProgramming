#!/usr/bin/env ruby
# encoding: utf-8

#This could be part of formula.rb, but formed into separate file for clarity reasons.

require_relative "formula"

module FormulaCut

  def self.cut(binary_op)
    raise ArgumentError.new "Argument have to be Formula::BinaryOperator" unless binary_op.is_a?(Formula::BinaryOperator)
    cut_operand1 = binary_op.operand1.cut
    cut_operand2 = binary_op.operand2.cut

    kind_operand1 = operand_kind(cut_operand1)
    kind_operand2 = operand_kind(cut_operand2)

    if (kind_operand1 == :const && kind_operand2 == :const)
      return cut_to_constant(binary_op.class, cut_operand1, cut_operand2)
    end
    #still a lot to do
  end

  ### helper funcs ###

  #Arguments are meant to be subclasses of Formula::BinaryOperator
  def combined_operator_class(operator1_class, operator2_class)
    return nil unless operator1_class.combines_with(operator2_class)
    
    com1 = operator1_class.commutative?
    com2 = operator2_class.commutative?
    if (com1 && com2) #both commutative
      return operator1_class #or operator2_class, whatever
    elsif not(com1 || com2) #both non-commutative
      return operator1_class.inverse_operator
    else #one non-commutative, return it
      return com1 ? operator2_class : operator1_class
    end
  end

  def cut_to_constant(operator_class, const1, const2)
      if (const1.is_a?(Formula::IntConstant)&&const2.is_a?(Formula::IntConstant))
        return Formula::IntConstant.new operator_class.operate(const1, const2)
      else
        return Formula::FloatConstant.new operator_class.operate(const1, const2)
      end
  end

  def operand_kind(op)
    return :const if op.is_a?(Formula::Constant)
    if op.is_a?(Formula::BinaryOperator)
      c1 = op.operand1.is_a?(Formula::Constant)
      c2 = op.operand2.is_a?(Formula::Constant)
      raise "Impossibru case!" if (c1 && c2)
      return :op_const if (c1 || c2)
    end
    return :unkind    
  end
end
