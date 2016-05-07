#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../sorting/sorting_vm"
require_relative "../sorting/expression"
require_relative "../sorting/expression_mutator"
require "test/unit"

class TestExpressionMutator < Test::Unit::TestCase

  def setup
    ExpressionMutator.vars_pool = [:x, :y, :z]
    ExpressionMutator.iterators_pool = [:i, :j, :k]
  end

  def test_random_epsilon
    rnd = ExpressionMutator::random_epsilon
    assert_kind_of(Expression::Epsilon, rnd)
  end

end
