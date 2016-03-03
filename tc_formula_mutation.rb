#!/usr/bin/env ruby
# encoding: utf-8

require_relative "formula"
require_relative "formula_mutation"
require "test/unit"

class TestFormulaMutation < Test::Unit::TestCase

  def test_var_list
    FormulaMutator::vars_list = [:x, :z]
    assert_equal([:x, :z], FormulaMutator::vars_list)
  end
end
