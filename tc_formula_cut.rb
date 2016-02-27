#!/usr/bin/env ruby
# encoding: utf-8

require_relative "formula_cut"
require "test/unit"


#Expose module methods for unit testing
module FormulaCut
  class << self
    public :cut_op_const
    public :combined_operator_class
    public :cut_to_constant
    public :operand_kind
  end
end


class TestFormulaCut < Test::Unit::TestCase

  #shorthands
  def setup
    @plus_op = Formula::AdditionOperator
    @minus_op = Formula::SubtractionOperator
    @mult_op = Formula::MultiplicationOperator
    @div_op = Formula::DivisionOperator
    @pow_op = Formula::PowerOperator

    @combo = Proc.new do |op1, op2|
      FormulaCut::combined_operator_class(op1, op2)
    end

    @cutc = Proc.new do |op, c1, c2|
      FormulaCut::cut_to_constant(op, c1, c2)
    end

    @kind = Proc.new do |op|
      FormulaCut::operand_kind(op)
    end
  end

  def test_cut_raise
    assert_raise(ArgumentError) do
      FormulaCut::cut(Formula::IntConstant.new 42)
    end
  end

  def test_cut_2_consts
    constInt8 = Formula::IntConstant.new 8
    constInt4 = Formula::IntConstant.new 4
    op = @plus_op.new(constInt8, constInt4)

    res = FormulaCut::cut(op)
    assert(res.is_a?(Formula::Constant))
    assert_equal(12, res.value)
    assert_equal("12", "#{res}")
  end

  def test_cut_const_op_const
    constInt8 = Formula::IntConstant.new 8
    constInt4 = Formula::IntConstant.new 4
    varX = Formula::Variable.new :x

    #8 + (4 + x)
    nested_op = @plus_op.new(constInt4, varX)
    op = @plus_op.new(constInt8, nested_op)
    res = FormulaCut::cut(op)
    assert_equal("(12+x)", "#{res}")

    #8 + (4 - x)
    nested_op = @minus_op.new(constInt4, varX)
    op = @plus_op.new(constInt8, nested_op)
    res = FormulaCut::cut(op)
    assert_equal("(12-x)", "#{res}")

    #8 - (4 - x)
    nested_op = @minus_op.new(constInt4, varX)
    op = @minus_op.new(constInt8, nested_op)
    res = FormulaCut::cut(op)
    assert_equal("(4+x)", "#{res}")

    #8 + (x - 4)
    nested_op = @minus_op.new(varX, constInt4)
    op = @plus_op.new(constInt8, nested_op)
    res = FormulaCut::cut(op)
    assert_equal("(4+x)", "#{res}")

    #8 - (x - 4)
    nested_op = @minus_op.new(varX, constInt4)
    op = @minus_op.new(constInt8, nested_op)
    res = FormulaCut::cut(op)
    assert_equal("(12-x)", "#{res}")

    #8 - (x + 4)
    nested_op = @plus_op.new(varX, constInt4)
    op = @minus_op.new(constInt8, nested_op)
    res = FormulaCut::cut(op)
    assert_equal("(4-x)", "#{res}")  
  end

  def test_combined_op
    # ++ => +
    assert_equal(@plus_op, @combo.call(@plus_op, @plus_op))
    # +- => -
    assert_equal(@minus_op, @combo.call(@plus_op, @minus_op))
    # -+ => -
    assert_equal(@minus_op, @combo.call(@minus_op, @plus_op))    
    # -- => +
    assert_equal(@plus_op, @combo.call(@minus_op, @minus_op))

    # ** => *
    assert_equal(@mult_op, @combo.call(@mult_op, @mult_op))
    # */ => /
    assert_equal(@div_op, @combo.call(@mult_op, @div_op))
    # /* => /
    assert_equal(@div_op, @combo.call(@div_op, @mult_op))    
    # // => *
    assert_equal(@mult_op, @combo.call(@div_op, @div_op))

    # +* not combines
    assert_equal(nil, @combo.call(@plus_op, @mult_op))
    # -/ not combines
    assert_equal(nil, @combo.call(@minus_op, @div_op))
    # +/ not combines
    assert_equal(nil, @combo.call(@plus_op, @div_op))
    # -* not combines
    assert_equal(nil, @combo.call(@minus_op, @mult_op))
  end

  def test_cut_to_const
    constInt8 = Formula::IntConstant.new 8
    constFloat4 = Formula::FloatConstant.new 4

    resIntInt = @cutc.call(@plus_op, constInt8, constInt8)
    assert_equal(true, resIntInt.is_a?(Formula::IntConstant))
    assert_equal(16, resIntInt.value)

    resIntFloat = @cutc.call(@plus_op, constInt8, constFloat4)
    assert_equal(true, resIntFloat.is_a?(Formula::FloatConstant))
    assert_equal(12.0, resIntFloat.value)

    resFloatFloat = @cutc.call(@plus_op, constFloat4, constFloat4)
    assert_equal(true, resFloatFloat.is_a?(Formula::FloatConstant))
    assert_equal(8.0, resFloatFloat.value)
  end

  def test_operand_kind
    constInt8 = Formula::IntConstant.new 8
    varX = Formula::Variable.new :x

    assert_equal(:const, @kind.call(constInt8))
    assert_equal(:unkind, @kind.call(varX))

    plus_c_v = @plus_op.new constInt8, varX
    assert_equal(:op_const, @kind.call(plus_c_v))

    plus_v_v = @plus_op.new varX, varX
    assert_equal(:unkind, @kind.call(plus_v_v))

    plus_c_c = @plus_op.new constInt8, constInt8
    assert_raise(RuntimeError) do
        #not designed to handle such operands
        @kind.call(plus_c_c)
    end
  end
end
