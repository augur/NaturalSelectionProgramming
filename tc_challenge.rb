#!/usr/bin/env ruby
# encoding: utf-8

require_relative "challenge"
require "test/unit"

class TestChallenge < Test::Unit::TestCase
  def test_model
    assert_raise(ArgumentError) do
      m = Challenge::Model.new
    end

    assert_raise(ArgumentError) do
      m = Challenge::Model.new {}
    end

    m = Challenge::Model.new {|x| x + 1}
    assert_equal(3, m.get_model_result(2))
  end

  def test_case
    c = Challenge::Case.new 2, 3
    assert_equal(2, c.input)
    assert_equal(3, c.model_result)
  end
  
  # non-abstract subclass for testing purposes
  class TestChallenger < Challenge::Challenger
  end

  def test_challenger
    assert_raise(RuntimeError) do
      c = Challenge::Challenger.new 3
    end

    assert_nothing_raised(RuntimeError) do
      tc = TestChallenger.new 3
      assert_equal(3, tc.solution)
    end
  end

  def test_build_case
    m = Challenge::Model.new {|x| x + 1}
    c = Challenge.build_case(m, 1)
    assert_equal(Challenge::Case, c.class)
    assert_equal(1, c.input)
    assert_equal(2, c.model_result)
  end

  def test_build_case_group
    m = Challenge::Model.new {|x| x + 1}
    
    ig = 1..3
    cg = Challenge.build_case_group(m, ig) #pass range
    assert_equal(ig.count, cg.size)
    assert_equal(2, cg[1].input)
    assert_equal(3, cg[1].model_result)

    ig = [1, 3, 5]
    cg = Challenge.build_case_group(m, ig) #pass array
    assert_equal(ig.count, cg.size)
    assert_equal(3, cg[1].input)
    assert_equal(4, cg[1].model_result)
  end

  # non-abstract subclass for testing purposes
  class TestChallenge < Challenge::Challenge
  end

  def test_challenge
    assert_raise(RuntimeError) do
      c = Challenge::Challenge.new(1, 2)
    end

    assert_raise(ArgumentError) do
      tc = TestChallenge.new(1, 2)
    end

    m = Challenge::Model.new {|x| x + 1}

    assert_raise(ArgumentError) do
      tc = TestChallenge.new(m, 2)
    end   

    ig = 1..3
    cg = Challenge.build_case_group(m, ig) 

    assert_nothing_raised(ArgumentError) do
      tc = TestChallenge.new(m, cg)
    end
  end

  ### major test of whole module functionality ###
  class TestChallenger < Challenge::Challenger
    def solve_case(c)
      c.challenger_result = solution + c.input
      c.aux_challenger_data = solution
      c
    end
  end

  class TestChallenge < Challenge::Challenge
    def calc_score(solved_case)
      score = (solved_case.model_result - solved_case.challenger_result).abs +
              solved_case.aux_challenger_data
      return score
    end

    def aggregate(scores)
      return scores.inject(0) {|agg, s| agg + s}
    end

    def compare_scores(score1, score2)
      score1 <=> score2
    end
  end

  def test_whole_module
    m = Challenge::Model.new {|x| x + 1}
    tcr = TestChallenger.new 2

    c1 = Challenge::build_case(m, 1)
    tcr.solve_case(c1)
    assert_equal(3, c1.challenger_result)
    assert_equal(2, c1.aux_challenger_data)

    cg = Challenge::build_case_group(m, 1..10)

    tc = TestChallenge.new(m, cg)
    assert_equal(3, tc.calc_score(c1))

    estimated_score = (1..10).inject(0) {|sum, i| sum + ((i+1)-(i+2)).abs + 2}

    # Challenge accepted! Return aggergated challenger score
    assert_equal(estimated_score, tc.accept(tcr))
    assert_equal(0, tc.compare_scores(estimated_score, tc.accept(tcr)))
  end
end
