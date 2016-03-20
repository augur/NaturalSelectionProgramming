#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'natural_selection'
require_relative 'challenge_formula'

module Evolution

  class FormulaEvolution
    attr_reader :strains
    attr_reader :rounds_to_win
    attr_reader :selection

    def initialize(case_group, base_formula, rounds_to_win, winners, randoms)
      challenge = ChallengeFormula::FormulaChallenge.new case_group
      @selection = NaturalSelection::NaturalSelection.new(challenge, winners, randoms)

      challenger = ChallengeFormula::FormulaChallenger.new base_formula
      base_strain = NaturalSelection::Strain.new(challenger, nil, 0, 0)
      @strains = [base_strain]

      @rounds_to_win = rounds_to_win
    end

    def run
      #
    end
  end
end
