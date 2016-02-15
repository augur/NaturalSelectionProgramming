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
      f = Constant.new
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
    assert_raise(ArgumentError) do
      v1 = Variable.new "string"
    end

    vars = {:x => 4, :y => 7}

    v2 = Variable.new :x
    assert_equal("x", "#{v2}")
    assert_equal(4, v2.value(vars))

    v3 = Variable.new :z
    assert_raise(ArgumentError) do
      v3.value(vars)
    end
  end
  
end

