#!/usr/bin/env ruby
# encoding: utf-8

require_relative "natural_selection"
require_relative "challenge_formula"

module Evolution

  class FormulaEvolution
    attr_reader :strains
    attr_reader :rounds_to_win
    attr_reader :selection
    attr_reader :base_strain

    def initialize(case_group, base_formula, rounds_to_win, winners, randoms)
      challenge = ChallengeFormula::FormulaChallenge.new case_group
      @selection = NaturalSelection::NaturalSelection.new(challenge, winners, randoms)

      challenger = ChallengeFormula::FormulaChallenger.new base_formula
      @base_strain = NaturalSelection::Strain.new(challenger, nil, 0, 0)
      @strains = [base_strain]

      @rounds_to_win = rounds_to_win
    end

    def run(cooldown = 0.0)
      round = 1
      complete = false
      begin
        mutants = @strains.map {|s| s.spawn_mutant(round)}
        @strains = (@strains + mutants + [@base_strain]).uniq {|s| s.challenger.solution.to_s}
        
        @strains = @selection.select(@strains)
        @strains.each {|s| s.next_round }

        #=== debug output ===
        puts "round №#{round}"
        @strains.first(10).each do |s|
          puts "Score: #{s.last_score.diff}; Price: #{s.last_score.price}; Lifetime: #{s.lifetime}"
        end
        #====================

        complete = @strains[0].lifetime > @rounds_to_win
        round = round.succ
        sleep cooldown
      end while !complete
        @strains[0].puts_evolution_chain
        puts "Winner: #{@strains[0].challenger.solution.to_s}"
        @strains[0]
    end
  end
end
