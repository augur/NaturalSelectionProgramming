#!/usr/bin/env ruby
# encoding: utf-8

require_relative "challenge_formula"
require "test/unit"

class TestChallengeFormula < Test::Unit::TestCase
  def test_formula_challenger
    f = Formula::Variable.new :x
    c = Challenge::Case.new({:x => 42}, 40)
    fc = ChallengeFormula::FormulaChallenger.new f
    fc.solve_case(c)

    assert_equal(42, c.challenger_result)
    assert_equal(Formula::FORMULA_CLASSES_PRICE[Formula::Variable], c.aux_challenger_data)
  end

  def test_formula_score
    fs = ChallengeFormula::FormulaScore.new 1, 5
    assert_equal(1, fs.diff)
    assert_equal(5, fs.price)

    fs = ChallengeFormula::FormulaScore.new ChallengeFormula::RESULT_EPSILON/2, 5
    assert_equal(0, fs.diff)
  end

  # TODO: FormulaChallenge
end
