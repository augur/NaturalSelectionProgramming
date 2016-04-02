#!/usr/bin/env ruby
# encoding: utf-8

module SortingVM

  class OperationLimitError < StandardError
  end


  class SortingVM 
    attr_reader :target
    attr_reader :result
    
    attr_reader :counter
    attr_reader :operation_limit
    
    attr_reader :memory

    def initialize(target, limit)
      @target = target
      @operation_limit = limit
    end

    def run(code)
      #preparations
      @counter = 0
      @memory = {}
      @result = @target.map {|e| e}
      #run
      code.each do |e|
        e.execute(self)
      end
    end

    ### utilities for instructions ###

    def rewrite_memory(memory)
      @memory = memory
    end

    def swap_elements(i1, i2)
      result[i1], result[i2] = result[i2], result[i1]
    end

    def inc_counter(inc = 1)
      @counter += inc
      raise OperationLimitError.new if @counter > @operation_limit
    end
  end

end
