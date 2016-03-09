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

    def initialize(input, model_result)
      @input = input
      @model_result = model_result
    end
  end


  class Challenge
  end

end
