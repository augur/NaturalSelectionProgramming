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
    assert_equal(nil, @svm.run([b]))
    assert_equal("x = 5\ny = 10", "#{b}")
    assert_equal(6, @svm.counter)
    
    b.indent = 2
    assert_equal("  x = 5\n  y = 10", "#{b}")
  end

  # x = true
  # while (x) do
  #   x = false
  # end
  def test_loop
    x = Expression::Var.new(:x)
    t = Expression::Const.new(true)
    f = Expression::Const.new(false)
    at = Expression::Assign.new(x,t)
    af = Expression::Assign.new(x,f)
    lb = Expression::Block.new(af)
    l = Expression::Loop.new(x, lb)
    all = Expression::Block.new(at, l)

    @svm.run([all])
    assert_equal(false, @svm.memory[:x])
    assert_equal("x = true\nwhile (x) do\n  x = false\nend", "#{all}")
    assert_equal(8, @svm.counter)
  end

  # while (x) do
  #   while (x) do
  #     x = x
  #   end
  # end    
  def test_nested_indent
    x = Expression::Var.new(:x)
    a = Expression::Assign.new(x,x)
    nb = Expression::Block.new(a)
    nl = Expression::Loop.new(x, nb)
    b = Expression::Block.new(nl)
    l = Expression::Loop.new(x, b)
    str = "while (x) do\n"+
          "  while (x) do\n"+
          "    x = x\n"+
          "  end\n"+
          "end"
    assert_equal(str, "#{l}")
  end

  def test_infinte_loop
    t = Expression::Const.new(true)
    b = Expression::Block.new(t)
    l = Expression::Loop.new(t, b)
    assert_equal("while (true) do\n  true\nend", "#{l}")
    assert_raise (SortingVM::OperationLimitError) do
      @svm.run([l])
    end
  end 
end
