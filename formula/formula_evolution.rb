#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../evolution"
require_relative "formula_challenge"

module FormulaEvolution
  class FormulaEvolution < Evolution::Evolution

    def initialize(case_group, base_formula, rounds_to_win, winners, randoms)
      challenge = FormulaChallenge::FormulaChallenge.new case_group
      challenger = FormulaChallenge::FormulaChallenger.new base_formula

      super(challenge, challenger, winners, randoms, rounds_to_win)
    end

  end
end
