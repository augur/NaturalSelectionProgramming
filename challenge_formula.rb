#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'challenge'
require_relative 'formula'

module ChallengeFormula

  RESULT_EPSILON = 0.001

  #@solution here is Formula
  class FormulaChallenger < Challenge::Challenger
    def solve_case(c)
      c.challenger_result = @solution.value(c.input) 
      c.aux_challenger_data = @solution.price
      c
    end
  end

  class FormulaScore
    attr_reader :diff
    attr_reader :price

    def initialize(diff, price)
      @diff = diff < RESULT_EPSILON ? 0 : diff
      @price = price
    end
  end

  class FormulaChallenge < Challenge::Challenge
    protected

    #score is float number. The lesser - the better (closer to model).
    def calc_score(solved_case)
      diff = (solved_case.model_result - solved_case.challenger_result).abs
      result = FormulaScore.new(diff, solved_case.aux_challenger_data)
      result
    end

    # fails on empty scores
    def aggregate(scores)
      total_diff = scores.inject(0) {|sum, s| sum + s.diff }
      price = scores[0].price
      FormulaScore.new(total_diff/scores.size, price)
    end

    public

    # -1 = score1 is better
    #  0 = scores are equal
    #  1 = score2 is better
    def compare_scores(score1, score2)
      cmp1 = score1.diff <=> score2.diff
      if (cmp1 == 0)
        return score1.price <=> score2.price
      else
        return cmp1
      end
    end    
  end
end
