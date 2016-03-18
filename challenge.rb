#!/usr/bin/env ruby
# encoding: utf-8

module Challenge

  # Model currently has same functionality as Proc,
  # however it can be more easily extended / inherited
  class Model
    def initialize(&block)
      raise ArgumentError.new unless (block_given? && block.arity == 1)
      @proc = Proc.new do |input|
        block.call input
      end
    end
        
    def get_model_result(input)
      @proc.call(input)
    end
  end

  class Case
    attr_reader :input
    attr_reader :model_result
    attr_accessor :challenger_result
    attr_accessor :aux_challenger_data

    def initialize(input, model_result)
      @input = input
      @model_result = model_result
    end
  end

  class Challenger
    attr_reader :solution

    def initialize(solution)
      raise "Abstract class construction" if self.instance_of? Challenger
      @solution = solution
    end

    def solve_case(c)
      #to be implemented in subclasses
    end
  end


  def self.build_case(model, input)
    Case.new(input, model.get_model_result(input))
  end

  def self.build_case_group(model, input_group)
    input_group.map { |i| build_case(model, i)}
  end
  

  class Challenge
    attr_reader :case_group

    # Abstract class. Rely on subclasses with defined score and comparison methods
    def initialize(case_group)
      raise "Abstract class construction" if self.instance_of? Challenge
      raise ArgumentError.new unless (case_group.is_a?(Enumerable) &&
                                      !case_group.empty?  &&
                                      case_group.all? {|c| c.is_a?(Case)})
      @case_group = case_group
    end

    def accept(challenger)
      scores = case_group.map do |c|
        calc_score(challenger.solve_case(c))
      end
      return aggregate(scores)
    end

    protected

    def calc_score(solved_case)
      #to be implemented in subclasses
    end

    def aggregate(scores)
      #to be implemented in subclasses
    end

    public

    # returns result as <=> (spaceship) operator
    def compare_scores(score1, score2)
      #to be implemented in subclasses
    end
  end

end
