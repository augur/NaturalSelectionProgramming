#!/usr/bin/env ruby
# encoding: utf-8

require_relative "formula"
require_relative "formula_mutation"
require "test/unit"

class TestFormulaMutation < Test::Unit::TestCase

  def setup
    FormulaMutator::vars_list = [:x, :y, :z]
  end

  def test_var_list
    FormulaMutator::vars_list = [:x, :z]
    assert_equal([:x, :z], FormulaMutator::vars_list)
  end

  ### test helper funcs ###

  def test_random_bop
    rbop = FormulaMutator::random_bop(FormulaMutator::random_operand,
                                      FormulaMutator::random_operand)
    assert(rbop.is_a?(Formula::BinaryOperator))
  end

  def test_random_operand
    ro = FormulaMutator::random_operand
    assert(ro.is_a?(Formula::Formula))
    assert(ro.is_a?(Formula::Constant) || ro.is_a?(Formula::Variable))
  end

  def test_random_variable
    rv = FormulaMutator::random_variable
    assert(rv.is_a?(Formula::Variable))
    assert(FormulaMutator::vars_list.include?("#{rv}".to_sym))
  end

  def test_random_constant
    rc = FormulaMutator::random_constant
    assert(rc.is_a?(Formula::Constant))
    assert(rc.value > -10 && rc.value < 10)
  end

  def test_random_int
    ri = FormulaMutator::random_int
    assert(ri.is_a?(Integer))
    assert(ri > -10 && ri < 10)
  end

  def test_random_float
    rf = FormulaMutator::random_float
    assert(rf.is_a?(Float))
    assert(rf > -10.0 && rf < 10.0)
  end

  ### test grows ###
  def test_grow_constant
    g = FormulaMutator::grow_constant(FormulaMutator::random_constant)
    assert(g.is_a?(Formula::Variable) || g.is_a?(Formula::BinaryOperator))
  end

  def test_grow_variable
    g = FormulaMutator::grow_variable(FormulaMutator::random_variable)
    assert(g.is_a?(Formula::BinaryOperator))
  end

  def test_grow_bop
    1000.times do
      bop = FormulaMutator::random_bop(FormulaMutator::random_operand, FormulaMutator::random_operand)
      g = FormulaMutator::grow_bop(bop)
      assert(bop.price < g.price)
    end
  end

  ### test shrinks ###

  def test_shrink_constant
    s = FormulaMutator::shrink_constant(FormulaMutator::random_constant)
    assert(s.is_a?(Formula::Constant))
  end

  def test_shrink_variable
    s = FormulaMutator::shrink_variable(FormulaMutator::random_variable)
    assert(s.is_a?(Formula::Constant))
  end

  def test_shrink_bop
    1000.times do
      bop = FormulaMutator::random_bop(FormulaMutator::random_operand, FormulaMutator::random_operand)
      s = FormulaMutator::shrink_bop(bop)
      assert(bop.price > s.price)
    end
  end

  ### test shifts ###

  def test_shift_constant
    s = FormulaMutator::shift_constant(FormulaMutator::random_constant)
    assert(s.is_a?(Formula::Constant))
  end

  def test_shift_variable
    s = FormulaMutator::shift_variable(FormulaMutator::random_variable)
    assert(s.is_a?(Formula::Variable))
  end

  def test_shift_bop
    1000.times do
      #create most priced operator
      pow_op = Formula::PowerOperator.new(FormulaMutator::random_operand,
                                          FormulaMutator::random_operand)
      s = FormulaMutator::shift_bop(pow_op)
      assert(pow_op.price >= s.price)
    end  
  end
end
