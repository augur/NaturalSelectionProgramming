#!/usr/bin/env ruby
# encoding: utf-8

require_relative "formula"
require "test/unit"

class TestFormula < Test::Unit::TestCase
  def test_abstract_classes
    assert_raise(RuntimeError) do
      f = Formula.new
    end
    
    assert_raise(RuntimeError) do
      c = Constant.new
    end
    
    assert_raise(RuntimeError) do
      bop = BinaryOperator.new(IntConstant.new(3), FloatConstant.new(4.0))
    end
  end
  
  def test_ints
    i = IntConstant.new 42
    assert_equal(42, i.value)
    assert_equal("42", "#{i}")
    assert_equal(i, i.cut)
    assert_equal(FORMULA_CLASSES_PRICE[IntConstant], i.price)
    
    i2 = IntConstant.new 3.14
    assert_equal(3, i2.value)
    
    i3 = IntConstant.new 2.71
    assert_equal(3, i2.value)
    
    assert_raise(ArgumentError) do
      i4 = IntConstant.new "am string"
    end
  end
  
  def test_floats
    f = FloatConstant.new 3.14
    assert_equal(3.14, f.value)
    assert_equal("3.140", "#{f}")
    assert_equal(f, f.cut)
    assert_equal(FORMULA_CLASSES_PRICE[FloatConstant], f.price)
    
    f2 = FloatConstant.new 42
    assert_equal(42.0, f2.value)
    
    assert_raise(ArgumentError) do
      f3 = FloatConstant.new "am string"
    end
    
    assert_raise(ArgumentError) do
      f4 = FloatConstant.new Float::NAN
    end

    assert_raise(ArgumentError) do
      f5 = FloatConstant.new Float::INFINITY
    end
  end

  def test_variables
    vars = {:x => 4, :y => 7}
    
    v = Variable.new :x
    assert_equal("x", "#{v}")
    assert_equal(4, v.value(vars))
    assert_equal(FORMULA_CLASSES_PRICE[Variable], v.price)

    v2 = Variable.new :z
    assert_raise(ArgumentError) do
      v2.value(vars)
    end
    
    assert_raise(NoMethodError) do
      v2.value
    end
    
    assert_raise(ArgumentError) do
      v3 = Variable.new "string"
    end
  end
  
  def test_binary_ops
    p1 = FloatConstant.new 3.0
    p2 = FloatConstant.new 2.0
    
    op = AdditionOperator.new p1, p2
    
    assert_equal(5.0, op.value)
    assert_equal("(3.000+2.000)", "#{op}")
    pr = FORMULA_CLASSES_PRICE[FloatConstant] * 2 +
         FORMULA_CLASSES_PRICE[AdditionOperator]
    assert_equal(pr, op.price)
    
    op2 = SubtractionOperator.new p1, p2
    assert_equal(1.0, op2.value)
    assert_equal("(3.000-2.000)", "#{op2}")
    pr = FORMULA_CLASSES_PRICE[FloatConstant] * 2 +
         FORMULA_CLASSES_PRICE[SubtractionOperator]
    assert_equal(pr, op2.price)
  end
  
  def test_bop_cut_1
    c1 = IntConstant.new 5
    c2 = IntConstant.new 3
    v = Variable.new :x
    vars = {:x => 4}
    
    #(c1+v)+c2
    bop1 = AdditionOperator.new(AdditionOperator.new(c1, v), c2)
    assert_equal(12, bop1.value(vars))
    assert_equal("((5+x)+3)", "#{bop1}")
    assert_equal("(8+x)", "#{bop1.cut}")
    
    #(c1+v)-c2
    bop2 = SubtractionOperator.new(AdditionOperator.new(c1, v), c2)
    assert_equal(6, bop2.value(vars))
    assert_equal("((5+x)-3)", "#{bop2}")
    assert_equal("(2+x)", "#{bop2.cut}")    
    
    #(c1-v)+c2
    bop3 = AdditionOperator.new(SubtractionOperator.new(c1, v), c2)
    assert_equal(4, bop3.value(vars))
    assert_equal("((5-x)+3)", "#{bop3}")
    assert_equal("(8-x)", "#{bop3.cut}")    

    #(c1-v)-c2
    bop4 = SubtractionOperator.new(SubtractionOperator.new(c1, v), c2)
    assert_equal(-2, bop4.value(vars))
    assert_equal("((5-x)-3)", "#{bop4}")
    assert_equal("(2-x)", "#{bop4.cut}")    
    
  end
end

