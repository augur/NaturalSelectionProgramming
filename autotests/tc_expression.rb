#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../sorting/sorting_vm"
require_relative "../sorting/expression"
require "test/unit"

#Expressions should be tested directly on SortingVM.
#It's meaningless to create mock version of SortingVM

class TestExpression < Test::Unit::TestCase

  def setup
    @svm = SortingVM::SortingVM.new([6, 4, 8, 2], 1000)
  end

  def teardown
    @svm = nil
  end  

  def test_epsilon
    e = Expression::Epsilon.new
    assert_equal(nil, @svm.run([e]))
    assert_equal("nil", "#{e}")
    assert_equal(0, @svm.counter)
  end

  def test_const
    assert_raise(ArgumentError) do 
      c = Expression::Const.new("not int")
    end
    c = Expression::Const.new(42)
    assert_equal(42, @svm.run([c]))
    assert_equal("42", "#{c}")
    assert_equal(1, @svm.counter)

    c = Expression::Const.new(false)
    assert_equal(false, @svm.run([c]))
    assert_equal("false", "#{c}")
    assert_equal(1, @svm.counter)
  end

  def test_var
    assert_raise(ArgumentError) do 
      v = Expression::Var.new("not a symbol")
    end

    v = Expression::Var.new(:x)
    assert_equal(nil, @svm.run([v])) #uninitialized by default
    assert_equal("x", "#{v}")
    assert_equal(1, @svm.counter)
  end

  def test_assign
    v = Expression::Var.new(:x)
    c = Expression::Const.new(42)

    assert_raise(ArgumentError) do
      a = Expression::Assign.new(v, 42)
    end

    assert_raise(ArgumentError) do
      a = Expression::Assign.new(:x, c)
    end

    a = Expression::Assign.new(v, c)
    assert_equal(42, @svm.run([a]))
    assert_equal(42, @svm.memory[v.name])
    assert_equal("x = 42", "#{a}")
    assert_equal(3, @svm.counter)
  end

  def test_block
    x = Expression::Var.new(:x)
    y = Expression::Var.new(:y)
    cx = Expression::Const.new(5) 
    cy = Expression::Const.new(10)

    ax = Expression::Assign.new(x, cx)
    ay = Expression::Assign.new(y, cy)

    assert_raise(ArgumentError) do  
      b = Expression::Block.new("not a expr")
    end
    b = Expression::Block.new(ax, ay)
    assert_equal(10, @svm.run([b]))
    assert_equal("x = 5; y = 10", "#{b}")
    assert_equal(6, @svm.counter)
  end
end
