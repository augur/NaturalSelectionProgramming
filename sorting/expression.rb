#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'sorting_vm'

=begin

What actual expressions do we have:

 CONST

 VAR

 ASSIGN (VAR) = (EXPR)

 BLOCK (EXPR*)
 
 WHILE (EXPR) do
  (BLOCK)

NYI:
 TIMES (EXPR) do
  |i| (BLOCK)
  

=end

module Expression

  #base abstract class
  class Expression
    def execute(vm)
    end
  end

  class Const < Expression
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def execute(vm)
      @value
    end
  end

  class Var < Expression
    attr_reader :variable

    def initalize(variable)
      @variable = variable
    end

    def execute(vm)
      vm.memory[@variable]
    end
  end

  class Assign < Expression
    attr_reader :var
    attr_reader :expr

    def initialize(var, expr)
      @var = var
      @expr = expr
    end

    def execute(vm)
      vm.memory[@var.variable] = expr.execute(vm)
    end
  end

  class Block < Expression
    attr_reader :expressions

    def initialize(*expressions)
      @expressions = expressions
    end

    def execute(vm)
      @expressions.each do |e|
        e.execute(vm)
      end
    end
  end

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
