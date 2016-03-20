#!/usr/bin/env ruby
# encoding: utf-8

require_relative "challenge"
require_relative "formula"

module ChallengeFormula

  RESULT_EPSILON = 0.001

  #@solution here is Formula
  class FormulaChallenger < Challenge::Challenger

    def initialize(f)
      raise ArgumentError.new unless f.is_a?(Formula::Formula)
      super(f)
    end

    def solve_case(c)
      begin
        c.challenger_result = @solution.value(c.input) 
      rescue Exception => e
        c.challenger_result = nil
        #puts "#{@solution.to_s}, #{c.input}, #{e.message}" #debug output
      end
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
      if (solved_case.challenger_result.nil?) or
         ((solved_case.challenger_result.respond_to?(:finite?))and(!solved_case.challenger_result.finite?))
        diff = Float::MAX
      else
        diff = (solved_case.model_result.to_f - solved_case.challenger_result.to_f).abs
      end
      result = FormulaScore.new(diff, solved_case.aux_challenger_data)
      result
    end

    # fails on empty scores
    def aggregate(scores)
      total_diff = (scores.inject(0) {|sum, s| sum + s.diff }).to_f
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
