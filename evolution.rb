#!/usr/bin/env ruby
# encoding: utf-8

require_relative "natural_selection"

module Evolution

  class Evolution
    attr_reader :selection    
    attr_reader :rounds_to_win    
    
    attr_reader :base_strain
    attr_reader :strains

    def initialize(challenge, challenger, winners, randoms, rounds_to_win)
      @selection = NaturalSelection::NaturalSelection.new(challenge, winners, randoms)
      @rounds_to_win = rounds_to_win

      @base_strain = NaturalSelection::Strain.new(challenger, nil, 0, 0)
      @strains = [base_strain]            
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
          puts "#{s.last_score}; Generation: #{s.generation}; Lifetime: #{s.lifetime}"
        end
        #====================

        complete = @strains[0].lifetime > @rounds_to_win
        round = round.succ
        sleep cooldown
      end while !complete
      @strains[0].puts_evolution_chain
      puts "Round №#{round}, Winner: #{@strains[0].challenger.solution.to_s}"
      puts "#{@strains[0].last_score}; Generation: #{@strains[0].generation}; Lifetime: #{@strains[0].lifetime}"
      @strains[0]
    end
  end


end
