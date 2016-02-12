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
    assert_equal("42", i.string_view)
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
    assert_equal("3.140", f.string_view)
    assert_equal(f, f.cut)
    assert_equal(FORMULA_CLASSES_PRICE[FloatConstant], f.price)
    
    f2 = FloatConstant.new 42
    assert_equal(42.0, f2.value)
    
    assert_raise(ArgumentError) do
      f3 = FloatConstant.new "am string"
    end
  end
  
end

