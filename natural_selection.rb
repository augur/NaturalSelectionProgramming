#!/usr/bin/env ruby
# encoding: utf-8

require_relative "challenge"

module NaturalSelection

  class Strain
    attr_reader :challenger

    attr_reader :ancestor
    attr_reader :generation
    attr_reader :round

    def initialize(challenger, ancestor, generation, round)
      raise ArgumentError.new unless challenger.is_a?(Challenge::Challenger)
      @challenger = challenger
      @ancestor = ancestor
      @generation = generation
      @round = round
    end

    def spawn_mutant(round)
      mutant_solution = challenger.solution.mutate
      mutant_challenger = challenger.class.new mutant_solution
      mutant_generation = generation.succ
      return self.class.new(mutant_challenger, self, mutant_generation, round)
    end

    def score(challenge)
      return @score unless (@score.nil? or challenge != @challenge)
      @challenge = challenge
      @score = @challenge.accept(@challenger)
      @score
    end
  end

  class NaturalSelection

    attr_reader :challenge
    attr_reader :winners
    attr_reader :randoms

    # main method
    def select(strains)
      #
    end
  end
end
