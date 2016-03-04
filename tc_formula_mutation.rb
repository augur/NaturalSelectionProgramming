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
end
