#!/usr/bin/env ruby
# encoding: utf-8

require_relative "formula_cut"
require "test/unit"


#Expose module methods for unit testing
module FormulaCut
  module_function :combined_operator_class
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
end
