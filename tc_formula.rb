#!/usr/bin/env ruby
# encoding: utf-8

require_relative "formula"
require "test/unit"

class TestFormula < Test::Unit::TestCase
  def test_abstract_classes
    assert_raise(RuntimeError) do
      f = Formula::Formula.new
    end
    
    assert_raise(RuntimeError) do
      c = Formula::Constant.new
    end
    
    assert_raise(RuntimeError) do
      bop = Formula::BinaryOperator.new(Formula::IntConstant.new(3), Formula::FloatConstant.new(4.0))
    end
  end
  
  def test_ints
    i = Formula::IntConstant.new 42
    assert_equal(42, i.value)
    assert_equal("42", "#{i}")
    assert_equal(i, i.cut)
    assert_equal(Formula::FORMULA_CLASSES_PRICE[Formula::IntConstant], i.price)
    
    i2 = Formula::IntConstant.new 3.14
    assert_equal(3, i2.value)
    
    i3 = Formula::IntConstant.new 2.71
    assert_equal(3, i2.value)
    
    assert_raise(ArgumentError) do
      i4 = Formula::IntConstant.new "am string"
    end
  end
  
  def test_floats
    f = Formula::FloatConstant.new 3.14
    assert_equal(3.14, f.value)
    assert_equal("3.140", "#{f}")
    assert_equal(f, f.cut)
    assert_equal(Formula::FORMULA_CLASSES_PRICE[Formula::FloatConstant], f.price)
    
    f2 = Formula::FloatConstant.new 42
    assert_equal(42.0, f2.value)
    
    assert_raise(ArgumentError) do
      f3 = Formula::FloatConstant.new "am string"
    end
    
    assert_raise(ArgumentError) do
      f4 = Formula::FloatConstant.new Float::NAN
    end

    assert_raise(ArgumentError) do
      f5 = Formula::FloatConstant.new Float::INFINITY
    end
  end

  def test_variables
    vars = {:x => 4, :y => 7}
    
    v = Formula::Variable.new :x
    assert_equal("x", "#{v}")
    assert_equal(4, v.value(vars))
    assert_equal(Formula::FORMULA_CLASSES_PRICE[Formula::Variable], v.price)

    v2 = Formula::Variable.new :z
    assert_raise(ArgumentError) do
      v2.value(vars)
    end
    
    assert_raise(NoMethodError) do
      v2.value
    end
    
    assert_raise(ArgumentError) do
      v3 = Formula::Variable.new "string"
    end
  end
  
  def test_binary_ops
    p1 = Formula::FloatConstant.new 3.0
    p2 = Formula::FloatConstant.new 2.0
    
    op = Formula::AdditionOperator.new p1, p2
    assert_equal(5.0, op.value)
    assert_equal("(3.000+2.000)", "#{op}")
    pr = Formula::FORMULA_CLASSES_PRICE[Formula::FloatConstant] * 2 +
         Formula::FORMULA_CLASSES_PRICE[Formula::AdditionOperator]
    assert_equal(pr, op.price)
    #assert_equal("5.000", "#{op.cut}")
    assert_equal(true, op.class.commutative?)
    
    op2 = Formula::SubtractionOperator.new p1, p2
    assert_equal(1.0, op2.value)
    assert_equal("(3.000-2.000)", "#{op2}")
    pr = Formula::FORMULA_CLASSES_PRICE[Formula::FloatConstant] * 2 +
         Formula::FORMULA_CLASSES_PRICE[Formula::SubtractionOperator]
    assert_equal(pr, op2.price)
    #assert_equal("1.000", "#{op2.cut}")
    assert_equal(false, op2.class.commutative?)
    assert_equal(Formula::AdditionOperator, op2.class.inverse_operator)

    op3 = Formula::MultiplicationOperator.new p1, p2
    assert_equal(6.0, op3.value)
    assert_equal("(3.000*2.000)", "#{op3}")
    pr = Formula::FORMULA_CLASSES_PRICE[Formula::FloatConstant] * 2 +
         Formula::FORMULA_CLASSES_PRICE[Formula::MultiplicationOperator]    
    assert_equal(pr, op3.price)
    #assert_equal("6.000", "#{op3.cut}")
    assert_equal(true, op3.class.commutative?)
  end

  #should migrate to tc_formula_cut.rb  
  def test_bop_cut_1
    c1 = Formula::IntConstant.new 5
    c2 = Formula::IntConstant.new 3
    v = Formula::Variable.new :x
    vars = {:x => 4}
    
    return

    #(c1+v)+c2
    bop1 = Formula::AdditionOperator.new(Formula::AdditionOperator.new(c1, v), c2)
    assert_equal(12, bop1.value(vars))
    assert_equal("((5+x)+3)", "#{bop1}")
    assert_equal("(8+x)", "#{bop1.cut}")
    
    #(c1+v)-c2
    bop2 = Formula::SubtractionOperator.new(Formula::AdditionOperator.new(c1, v), c2)
    assert_equal(6, bop2.value(vars))
    assert_equal("((5+x)-3)", "#{bop2}")
    assert_equal("(2+x)", "#{bop2.cut}")    
    
    #(c1-v)+c2
    bop3 = Formula::AdditionOperator.new(Formula::SubtractionOperator.new(c1, v), c2)
    assert_equal(4, bop3.value(vars))
    assert_equal("((5-x)+3)", "#{bop3}")
    assert_equal("(8-x)", "#{bop3.cut}")    

    #(c1-v)-c2
    bop4 = Formula::SubtractionOperator.new(Formula::SubtractionOperator.new(c1, v), c2)
    assert_equal(-2, bop4.value(vars))
    assert_equal("((5-x)-3)", "#{bop4}")
    assert_equal("(2-x)", "#{bop4.cut}")    
  end
end

