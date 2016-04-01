#!/usr/bin/env ruby
# encoding: utf-8

# Provides tests for both evolution.rb and evolution_formula.rb
# Blame me for laziness

require_relative "../evolution"
require_relative "../challenge"
require_relative "../formula/formula_evolution"

require "test/unit"

class TestEvolution < Test::Unit::TestCase

  def test_formula_evolution_init
    m = Challenge::Model.new {|input| input[:x] + 5}
    ig = (0...5).map {|i| {:x => i}}
    cg = Challenge::build_case_group(m, ig)    

    f = Formula::Variable.new :x

    assert_raise(ArgumentError) do
      FormulaEvolution::FormulaEvolution.new(0, f, 1, 1, 1)
    end

    assert_raise(ArgumentError) do
      FormulaEvolution::FormulaEvolution.new(cg, 0, 1, 1, 1)
    end

    assert_nothing_raised do
      FormulaEvolution::FormulaEvolution.new(cg, f, 1, 1, 1)
    end
  end

  def test_formula_evolution_run
    m = Challenge::Model.new {|input| input[:x] + 5}
    ig = (0...5).map {|i| {:x => i}}
    cg = Challenge::build_case_group(m, ig)    

    FormulaMutator::vars_list = [:x]
    f = Formula::Variable.new :x

    fe = FormulaEvolution::FormulaEvolution.new(cg, f, 32, 1, 1)
    win = fe.run
    assert(win.last_score.diff < 5)
    assert(win.generation > 0)
    assert_equal(33, win.lifetime)
  end

end
