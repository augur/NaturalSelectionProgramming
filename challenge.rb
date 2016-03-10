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


  def self.build_case(model, input)
    Case.new(input, model.get_model_result(input))
  end

  def self.build_case_group(model, input_group)
    input_group.map { |i| build_case(model, i)}
  end
  

  class Challenge
    attr_reader :model
    attr_reader :case_group

    #Abstract class. Rely on subclasses with defined score and comparison methods
    def initialize(model, case_group)
      @model = model
      @case_group = case_group
    end

    def accept(challenger)
    end

    protected

    def calc_score(solved_case)
    end

    def aggregate(scores)
    end

    def compare_agg_scores(agg_score1, agg_score2)
    end
  end

end
