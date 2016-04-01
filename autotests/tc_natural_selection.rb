#!/usr/bin/env ruby
# encoding: utf-8



require_relative "../natural_selection"
require_relative "../formula/formula_challenge"
require "test/unit"

class TestNaturalSelection < Test::Unit::TestCase

  def setup
    FormulaMutator::vars_list = [:x]
  end

  def test_strain
    fc = FormulaChallenge::FormulaChallenger.new Formula::IntConstant.new 34

    s = NaturalSelection::Strain.new(fc, nil, 1, 42)
    assert_equal(fc, s.challenger)
    assert_equal(nil, s.ancestor)
    assert_equal(1, s.generation)
    assert_equal(42, s.round)
    s.next_round.next_round
    assert_equal(2, s.lifetime)

    ns = s.spawn_mutant(59)
    assert_not_equal(fc.solution.to_s, ns.challenger.solution.to_s)
    assert_equal(s, ns.ancestor)
    assert_equal(2, ns.generation)
    assert_equal(59, ns.round)

    m = Challenge::Model.new {|input| input[:x] + 5}
    ig = (0...5).map {|i| {:x => i}}
    cg = Challenge::build_case_group(m, ig)
    fce = FormulaChallenge::FormulaChallenge.new(cg)    

    assert_equal(27, s.score(fce).diff)
  end

  def test_natural_selection
    fc5 = FormulaChallenge::FormulaChallenger.new Formula::IntConstant.new 5
    fc6 = FormulaChallenge::FormulaChallenger.new Formula::IntConstant.new 6
    fc7 = FormulaChallenge::FormulaChallenger.new Formula::IntConstant.new 7

    s5 = NaturalSelection::Strain.new(fc5, nil, 1, 1)
    s6 = NaturalSelection::Strain.new(fc6, nil, 1, 1)
    s7 = NaturalSelection::Strain.new(fc7, nil, 1, 1)

    m = Challenge::Model.new {|input| 10}
    ig = (0...5).map {|i| {:x => i}}
    cg = Challenge::build_case_group(m, ig)
    fce = FormulaChallenge::FormulaChallenge.new(cg)

    ns = NaturalSelection::NaturalSelection.new(fce, 1, 1)
    assert_equal(fce, ns.challenge)
    assert_equal(1, ns.winners_count)
    assert_equal(1, ns.randoms_count)

    res = ns.select([s5, s6, s7])
    assert_equal(2, res.count)
    assert_equal(s7, res[0])
    assert(res[1] == s6 || res[1] == s5)
  end

end