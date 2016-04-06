#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'sorting_vm'

module Expression

  #base abstract class
  class Expression
    #TODO raise on init
  end

  
  ### Primitives ###
  # NONE
  # CONST
  # VAR
  # ASSIGN

  #Empty Expression, NONE
  class Epsilon < Expression
    def execute(vm)
      nil
    end

    def to_s
      "nil"
    end
  end

  # just a CONST
  class Const < Expression
    attr_reader :value

    def initialize(value)
      raise ArgumentError.new unless value.is_a?(Integer)
      @value = value
    end

    def execute(vm)
      vm.inc_counter
      @value
    end

    def to_s
      @value.to_s
    end
  end

  #Variable in vm.memory, accessed by symbol-name
  class Var < Expression
    attr_reader :name

    def initialize(name)
      raise ArgumentError.new unless name.is_a?(Symbol)
      @name = name
    end

    def execute(vm)
      vm.inc_counter      
      vm.memory[@name]
    end

    def to_s
      @name.to_s
    end
  end

  #Assignment, result of expression saved to variable
  class Assign < Expression
    attr_reader :var
    attr_reader :expr

    def initialize(var, expr)
      raise ArgumentError.new unless var.is_a?(Var) and expr.is_a?(Expression)
      @var = var
      @expr = expr
    end

    def execute(vm)
      vm.inc_counter 2
      vm.memory[@var.name] = expr.execute(vm)
    end

    def to_s
      "#{@var} = #{@expr}"
    end
  end

  ### Sequences ###
  # BLOCK

  class Block < Expression
    attr_reader :expressions

    def initialize(*expressions)
      expressions.each do |e|
        raise ArgumentError.new unless e.is_a?(Expression)
      end
      @expressions = expressions
    end

    def execute(vm)
      last = nil
      @expressions.each do |e|
        last = e.execute(vm)
      end
      last
    end

    def to_s
      @expressions.join("; ")
    end
  end

  #TODO from here

  class Loop < Expression
    attr_reader :condition
    attr_reader :block

    def initialize(cond, block)
      @condition = cond
      @block = block
    end

    def execute(vm)
      while (@condition.execute(vm)) do
        @block.execute(vm)
      end
    end
  end

end
