#!/usr/bin/env ruby
# encoding: utf-8

require_relative "natural_selection"
require_relative "challenge_formula"
require "test/unit"

class TestNaturalSelection < Test::Unit::TestCase

  def setup
    FormulaMutator::vars_list = [:x]
  end


  def test_strain
    fc = ChallengeFormula::FormulaChallenger.new Formula::IntConstant.new 34

    s = NaturalSelection::Strain.new(fc, nil, 1, 42)
    assert_equal(fc, s.challenger)
    assert_equal(nil, s.ancestor)
    assert_equal(1, s.generation)
    assert_equal(42, s.round)

    ns = s.spawn_mutant(59)
    assert_not_equal(fc.solution.to_s, ns.challenger.solution.to_s)
    assert_equal(s, ns.ancestor)
    assert_equal(2, ns.generation)
    assert_equal(59, ns.round)

    m = Challenge::Model.new {|input| input[:x] + 5}
    ig = (0...5).map {|i| {:x => i}}
    cg = Challenge::build_case_group(m, ig)
    fce = ChallengeFormula::FormulaChallenge.new(m, cg)    

    assert_equal(27, s.score(fce).diff)
  end

end