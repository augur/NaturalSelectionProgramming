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
    assert_equal(nil, @svm.run(e))
    assert_equal("nil", "#{e}")
    assert_equal(0, @svm.counter)
  end

  def test_const
    assert_raise(ArgumentError) do
      c = Expression::Const.new("not int")
    end
    c = Expression::Const.new(42)
    assert_equal(42, @svm.run(c))
    assert_equal("42", "#{c}")
    assert_equal(1, @svm.counter)

    c = Expression::Const.new(false)
    assert_equal(false, @svm.run(c))
    assert_equal("false", "#{c}")
    assert_equal(1, @svm.counter)
  end

  def test_tsize
    s = Expression::TSize.new
    assert_equal(4, @svm.run(s))
    assert_equal("result.size", "#{s}")
  end

  # x = 2
  # result[x]
  def test_element
    c = Expression::Const.new(2)
    x = Expression::Var.new(:x)
    a = Expression::Assign.new(x, c)
    e = Expression::Element.new(x)
    assert_equal(8, @svm.run(a, e))
    assert_equal("result[x]", "#{e}")
  end

  def test_var
    assert_raise(ArgumentError) do
      v = Expression::Var.new("not a symbol")
    end

    v = Expression::Var.new(:x)
    assert_equal(nil, @svm.run(v)) #uninitialized by default
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
    assert_equal(42, @svm.run(a))
    assert_equal(42, @svm.memory[v.name])
    assert_equal("x = 42", "#{a}")
    assert_equal(3, @svm.counter)
  end

  def test_succ
    c = Expression::Const.new(42)
    s = Expression::Succ.new(c)
    assert_equal(43, @svm.run(s))
    assert_equal(2, @svm.counter)
    assert_equal("42 + 1", "#{s}")
  end

  def test_pred
    c = Expression::Const.new(42)
    s = Expression::Pred.new(c)
    assert_equal(41, @svm.run(s))
    assert_equal(2, @svm.counter)
    assert_equal("42 - 1", "#{s}")
  end

  def test_equal
    x = Expression::Var.new(:x)
    n = Expression::Epsilon.new
    f = Expression::Const.new(false)
    e = Expression::Equal.new(x, n)
    assert_equal(true, @svm.run(e))
    e = Expression::Equal.new(x, f)
    assert_equal(false, @svm.run(e))
    assert_equal("x == false", "#{e}")
  end

  def test_nequal
    x = Expression::Var.new(:x)
    n = Expression::Epsilon.new
    f = Expression::Const.new(false)
    e = Expression::Nequal.new(x, n)
    assert_equal(false, @svm.run(e))
    e = Expression::Nequal.new(x, f)
    assert_equal(true, @svm.run(e))
    assert_equal("x != false", "#{e}")
  end

  def test_bigger
    c5 = Expression::Const.new(5)
    c2 = Expression::Const.new(2)
    b = Expression::Bigger.new(c5, c2)
    assert_equal(true, @svm.run(b))
    b = Expression::Bigger.new(c2, c5)
    assert_equal(false, @svm.run(b))
    assert_equal("2 > 5", "#{b}")
  end

  def test_lesser
    c5 = Expression::Const.new(5)
    c2 = Expression::Const.new(2)
    l = Expression::Lesser.new(c5, c2)
    assert_equal(false, @svm.run(l))
    l = Expression::Lesser.new(c2, c5)
    assert_equal(true, @svm.run(l))
    assert_equal("2 < 5", "#{l}")
  end


  def test_add
    c5 = Expression::Const.new(5)
    c2 = Expression::Const.new(2)
    a = Expression::Add.new(c5, c2)
    assert_equal(7, @svm.run(a))
    assert_equal("5 + 2", "#{a}")
  end

  def test_subt
    c5 = Expression::Const.new(5)
    c2 = Expression::Const.new(2)
    s = Expression::Subt.new(c5, c2)
    assert_equal(3, @svm.run(s))
    assert_equal("5 - 2", "#{s}")
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
    assert_equal(nil, @svm.run(b))
    assert_equal("x = 5\ny = 10", "#{b}")
    assert_equal(6, @svm.counter)

    b.indent = 2
    assert_equal("  x = 5\n  y = 10", "#{b}")
  end

  def test_swap
    x = Expression::Var.new(:x)
    y = Expression::Var.new(:y)

    cx = Expression::Const.new(1)
    cy = Expression::Const.new(2)

    ax = Expression::Assign.new(x, cx)
    ay = Expression::Assign.new(y, cy)

    sw = Expression::Swap.new(x, y)

    b = Expression::Block.new(ax, ay, sw)
    b.indent = 2

    @svm.run(b)

    assert_equal(8, @svm.result[1])
    assert_equal(4, @svm.result[2])
    assert_equal(14, @svm.counter)

    code = "  x = 1\n"+
    "  y = 2\n"+
    "  i1 = x\n"+
    "  i2 = y\n"+
    "  result[i1], result[i2] = result[i2], result[i1]"

    assert_equal(code, "#{b}")
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

    @svm.run(all)
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
      @svm.run(l)
    end
  end

  #  x = 0
  #  2.to(5) do |i|
  #      x = x + 1
  #  end
  def test_for
    c0 = Expression::Const.new(0)
    c2 = Expression::Const.new(2)
    c5 = Expression::Const.new(5)
    x = Expression::Var.new(:x)
    a = Expression::Assign.new(x, c0)
    s = Expression::Succ.new(x)
    ia = Expression::Assign.new(x, s)
    ib = Expression::Block.new(ia)
    f = Expression::Upto.new(c2, c5, ib)
    ob = Expression::Block.new(a, f)
    @svm.run(ob)
    assert_equal(4, @svm.memory[:x])
    assert_equal(29, @svm.counter)
    str="x = 0\n"\
    "(2).upto(5) do |i|\n"\
    "  x = x + 1\n"\
    "end"
    assert_equal(str, "#{ob}")
  end

  # (1).upto(2) do |i|
  #   (3).downto(2) do |j|
  #     swap here(i, j)
  #   end
  # end
  def test_nested_for
    c1 = Expression::Const.new(1)
    c2 = Expression::Const.new(2)
    c3 = Expression::Const.new(3)
    i = Expression::Iterator.new(:i)
    j = Expression::Iterator.new(:j)
    sw = Expression::Swap.new(i, j)
    ifor = Expression::Downto.new(c3, c2, sw)
    b = Expression::Block.new(ifor)
    ofor = Expression::Upto.new(c1, c2, b)
    @svm.run(ofor)
    assert_equal([6, 8, 4, 2], @svm.result)
    str = ""\
    "(1).upto(2) do |i|\n"\
    "  (3).downto(2) do |j|\n"\
    "    i1 = i\n"\
    "    i2 = j\n"\
    "    result[i1], result[i2] = result[i2], result[i1]\n"\
    "  end\n"\
    "end"
    assert_equal(str, "#{ofor}")
    assert_equal(50, @svm.counter)
  end

  def test_if
    ct = Expression::Const.new(true)
    cf = Expression::Const.new(false)
    x = Expression::Var.new(:x)
    at = Expression::Assign.new(x, ct)
    af = Expression::Assign.new(x, cf)
    bt = Expression::Block.new(at)
    bf = Expression::Block.new(af)
    _if = Expression::If.new(ct, bt, bf)
    @svm.run(_if)

    assert_equal(true, @svm.memory[:x])

    _if = Expression::If.new(cf, bt, bf)
    @svm.run(_if)

    assert_equal(false, @svm.memory[:x])

    str =
    "if false\n"\
    "  x = true\n"\
    "else\n"\
    "  x = false\n"\
    "end"
    assert_equal(str, "#{_if}")
  end
end
