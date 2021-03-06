#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../formula/formula_challenge"
require "test/unit"

class TestFormulaChallenge < Test::Unit::TestCase
  def test_formula_challenger
    f = Formula::Variable.new :x
    c = Challenge::Case.new({:x => 42}, 40)
    fc = FormulaChallenge::FormulaChallenger.new f
    fc.solve_case(c)

    assert_equal(42, c.challenger_result)
    assert_equal(Formula::FORMULA_CLASSES_PRICE[Formula::Variable], c.aux_challenger_data)
  end

  def test_formula_score
    fs = FormulaChallenge::FormulaScore.new 1, 5
    assert_equal(1, fs.diff)
    assert_equal(5, fs.price)
    assert_equal(5, fs.components[1])

    fs = FormulaChallenge::FormulaScore.new FormulaChallenge::RESULT_EPSILON/2, 5
    assert_equal(0, fs.diff)
  end

  def test_formula_challenge

    m = Challenge::Model.new {|input| input[:x] + 5}
    ig = (0...5).map {|i| {:x => i}}
    cg = Challenge::build_case_group(m, ig)

    fce = FormulaChallenge::FormulaChallenge.new(cg)

    o1 = Formula::Variable.new :x
    o2 = Formula::IntConstant.new 3
    f = Formula::AdditionOperator.new(o1, o2)

    fcer = FormulaChallenge::FormulaChallenger.new f

    score = fce.accept(fcer)
    assert_equal(2, score.diff)
    #Var + Int+ AddOp = 5 + 1 + 10 = 16
    assert_equal(16, score.price)

    fs1 = FormulaChallenge::FormulaScore.new 5, 5
    fs2 = FormulaChallenge::FormulaScore.new 1, 1
    fs3 = FormulaChallenge::FormulaScore.new 1, 5
    fs4 = FormulaChallenge::FormulaScore.new 5, 1

    fss = [fs1, fs2, fs3, fs4].sort {|a,b| fce.compare_scores(a, b)}
    assert_equal([fs2, fs3, fs4, fs1], fss)
  end

  def test_formula_challenger_fails
    # 2 / x
    f = Formula::DivisionOperator.new(Formula::IntConstant.new(2), Formula::Variable.new(:x))

    #whatever model
    m = Challenge::Model.new {|input| input[:x] + 5}
    c = Challenge::build_case(m, {:x => 0})
    fcer = FormulaChallenge::FormulaChallenger.new f
    
    c = fcer.solve_case(c)
    assert_equal(nil, c.challenger_result)

    #definitely NOT a formula
    notf = m
    assert_raise(ArgumentError) do
      fcer = FormulaChallenge::FormulaChallenger.new notf
    end
  end
end
