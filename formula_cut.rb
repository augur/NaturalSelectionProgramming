#!/usr/bin/env ruby
# encoding: utf-8

#This could be part of formula.rb, but formed into separate file for clarity reasons.

module BinaryOperatorCut

  def cut
    binary_op = self #a bit clumsy assignment, step from module_function to mixin
    raise ArgumentError.new "Argument have to be Formula::BinaryOperator" unless binary_op.is_a?(Formula::BinaryOperator)
    cut_operand1 = binary_op.operand1.cut
    cut_operand2 = binary_op.operand2.cut

    kind_operand1 = BinaryOperatorCut::operand_kind(cut_operand1)
    kind_operand2 = BinaryOperatorCut::operand_kind(cut_operand2)

    if (kind_operand1 == :const && kind_operand2 == :const)
      return BinaryOperatorCut::cut_to_constant(binary_op.class, cut_operand1, cut_operand2)
    elsif (kind_operand1 == :const && kind_operand2 == :op_const)
      unless BinaryOperatorCut::combined_operator_class(binary_op.class, cut_operand2.class).nil?
        return BinaryOperatorCut::cut_op_const(cut_operand1, binary_op.class, cut_operand2.operand1,
                            cut_operand2.class, cut_operand2.operand2, false)
      end
    elsif (kind_operand1 == :op_const && kind_operand2 == :const) 
      unless BinaryOperatorCut::combined_operator_class(cut_operand1.class, binary_op.class).nil?
        return BinaryOperatorCut::cut_op_const(cut_operand1.operand1, cut_operand1.class, cut_operand1.operand2,
                            binary_op.class, cut_operand2, true)
      end
    elsif (kind_operand1 == :op_const && kind_operand2 == :op_const)
      #It's not worth to implement it. This is rare one, and still lots of cases remain uncovered
    end

    #compound cut not applied, return what we have
    binary_op.class.new(cut_operand1, cut_operand2)
  end

  ### helper funcs ###

  #following code nearly copy-pasted from formula_cut_prototype.rb
  #there it is a bit less complex
  def self.cut_op_const(op1, sign1, op2, sign2, op3, sign1_is_nested)
    result_op1 = nil
    result_sign = nil
    result_op2 = nil
    if (BinaryOperatorCut::operand_kind(op1) == :unkind)
      const1      = op2
      const_sign  = combined_operator_class(sign1, sign2)
      const2      = op3

      result_op1  = op1
      result_sign = sign1
      result_op2  = cut_to_constant(const_sign, const1, const2)
    elsif (BinaryOperatorCut::operand_kind(op2) == :unkind)
      const1      = op1
      const_sign  = sign1_is_nested ? sign2 : combined_operator_class(sign1, sign2)
      const2      = op3

      result_op1  = cut_to_constant(const_sign, const1, const2)
      result_sign = sign1
      result_op2  = op2 
    elsif (BinaryOperatorCut::operand_kind(op3) == :unkind)
      const1      = op1
      const_sign  = sign1
      const2      = op2

      result_op1  = cut_to_constant(const_sign, const1, const2)
      result_sign = combined_operator_class(sign1, sign2)
      result_op2  = op3
    else
      raise "One operand should be unkind type"
    end

    result_sign.new result_op1, result_op2
  end


  #Arguments are meant to be subclasses of Formula::BinaryOperator
  def self.combined_operator_class(operator1_class, operator2_class)
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

  def self.cut_to_constant(operator_class, const1, const2)
    if (const1.is_a?(Formula::IntConstant)&&const2.is_a?(Formula::IntConstant))
      return Formula::IntConstant.new operator_class.operate(const1, const2)
    else
      return Formula::FloatConstant.new operator_class.operate(const1, const2)
    end
  end

  def self.operand_kind(op)
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
