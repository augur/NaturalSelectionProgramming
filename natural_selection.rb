#!/usr/bin/env ruby
# encoding: utf-8

require_relative "challenge"

module NaturalSelection

  class Strain
    attr_reader :challenger

    attr_reader :ancestor
    attr_reader :generation
    attr_reader :round
    attr_reader :lifetime

    def initialize(challenger, ancestor, generation, round)
      raise ArgumentError.new unless challenger.is_a?(Challenge::Challenger)
      @challenger = challenger
      @ancestor = ancestor
      @generation = generation
      @round = round
      @lifetime = 0
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

    def next_round()
      @lifetime = @lifetime.succ
      self
    end
  end

  class NaturalSelection
    attr_reader :challenge
    attr_reader :winners_count
    attr_reader :randoms_count

    def initialize(challenge, winners_count, randoms_count)
      @challenge = challenge
      @winners_count = winners_count
      @randoms_count = randoms_count
    end

    # main (and only?) method
    def select(strains)
      strains.sort! {|a,b| @challenge.compare_scores(a.score(@challenge), b.score(@challenge))}

      result = strains[0, winners_count]
      left = strains[winners_count, strains.count]
      counter = randoms_count
      while (not(left.empty?) && counter > 0)
        result.push(left.delete_at(rand(left.length))) #move random element from 'left' to 'result' arrays
        counter -= 1
      end
      result
    end
  end
end
