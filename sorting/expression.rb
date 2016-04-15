#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'sorting_vm'

#Quick hack: adds positive response on true.is_a?(Boolean) and 
#false.is_a?(Boolean) calls
module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

module Expression

  BASE_ITERATOR = :i
  BASE_VARIABLE = :x

  #base abstract class
  class Expression
    #TODO raise on init
  end
  
  ### Primitives ###
  # NIL
  # CONST
  # TARGET_SIZE
  # RESULT_ELEM
  # VAR
  # ASSIGN
  # SUCC
  # PRED
  # ITERATOR #TODO
  # COMPARISONS: EQUAL, NEQUAL, BIGGER, LESSER


  #Empty Expression, NIL, doesn't increase VM counter
  class Epsilon < Expression
    def execute(vm)
      nil
    end

    def to_s
      "nil"
    end
  end

  # just a CONST (either int or boolean)
  class Const < Expression
    attr_reader :value

    def initialize(value)
      raise ArgumentError.new unless value.is_a?(Integer) or value.is_a?(Boolean)
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

  #Just returns size of Target\Result array
  class TSize < Expression
    def execute(vm)
      vm.inc_counter
      vm.target.size 
    end

    def to_s
      "result.size"
    end
  end

  #Returns result-array element at given index
  class Element < Expression
    attr_reader :index

    def initialize(index)
      raise ArgumentError.new unless index.is_a?(Expression)
      @index = index
    end

    def execute(vm)
      vm.inc_counter
      vm.result[@index.execute(vm)]
    end

    def to_s
      "result[#{index}]"
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

  class Succ < Expression
    attr_reader :expr

    def initialize(expr)
      raise ArgumentError.new unless expr.is_a?(Expression)
      @expr = expr
    end

    def execute(vm)
      vm.inc_counter
      (expr.execute(vm)).succ
    end

    def to_s
      "#{expr} + 1"
    end
  end

  class Pred < Expression
    attr_reader :expr

    def initialize(expr)
      raise ArgumentError.new unless expr.is_a?(Expression)
      @expr = expr
    end

    def execute(vm)
      vm.inc_counter
      (expr.execute(vm)).pred
    end

    def to_s
      "#{expr} - 1"
    end
  end  

  #Abstract
  class Comparison < Expression
    attr_reader :left
    attr_reader :right

    def initialize(left, right)
      raise ArgumentError.new unless left.is_a?(Expression) and
                                     right.is_a?(Expression)
      #TODO raise abstract construction
      @left = left
      @right = right
    end

    def to_s
      "#{@left} "+sign+" #{@right}"
    end
  end

  class Equal < Comparison
    def sign
      "=="
    end

    def execute(vm)
      vm.inc_counter
      @left.execute(vm) == @right.execute(vm)
    end
  end

  class Nequal < Comparison
    def sign
      "!="
    end

    def execute(vm)
      vm.inc_counter
      @left.execute(vm) != @right.execute(vm)
    end    
  end

  class Bigger < Comparison
    def sign
      ">"
    end

    def execute(vm)
      vm.inc_counter
      @left.execute(vm) > @right.execute(vm)
    end  
  end

  class Lesser < Comparison
    def sign
      "<"
    end

    def execute(vm)
      vm.inc_counter
      @left.execute(vm) < @right.execute(vm)
    end      
  end

  ##########################

  class CommandStruct
    attr_accessor :indent
  end

  ### Sequences ###
  # BLOCK
  # SWAP

  class Block < CommandStruct
    attr_reader :expressions

    def initialize(*expressions)
      expressions.each do |e|
        raise ArgumentError.new unless e.is_a?(Expression) or e.is_a?(CommandStruct)
      end
      @expressions = expressions
      @indent = 0
    end

    def execute(vm)
      @expressions.each do |e|
        last = e.execute(vm)
      end
      nil
    end

    def to_s
      str_indent = " " * @indent
      (@expressions.map do |e|
        e.indent = @indent if e.is_a?(CommandStruct) 
        str_indent + e.to_s
       end).join("\n")
    end
  end

  class Swap < Block
    attr_reader :i1
    attr_reader :i2

    def initialize(i1, i2)
      raise ArgumentError.new unless i1.is_a?(Expression) and i2.is_a?(Expression)
      @i1 = i1
      @i2 = i2
      @indent = 0      
    end

    def execute(vm)
      vm.inc_counter 6
      vm.swap_elements(i1.execute(vm), i2.execute(vm))
    end

    def to_s
      str_indent = " " * @indent
      "i1 = #{i1}\n"+
      str_indent+"i2 = #{i2}\n"+
      str_indent+"result[i1], result[i2] = result[i2], result[i1]"
    end
  end

  ### Loops ###
  # Loop
  # Upto
  # Downto

  class Loop < CommandStruct
    attr_reader :condition
    attr_reader :block

    def initialize(cond, block)
      raise ArgumentError.new unless cond.is_a?(Expression) and block.is_a?(Block)
      @condition = cond
      @block = block
      self.indent = 0
    end

    def indent=(i)
      @indent = i
      @block.indent = i + 2
    end

    def execute(vm)
      while (@condition.execute(vm)) do
        @block.execute(vm)
      end
    end

    def to_s
      str_indent = " " * @indent 
      "while (#{@condition}) do\n#{@block}\n#{str_indent}end"
    end
  end

  class For < CommandStruct
    attr_reader :from
    attr_reader :to
    attr_reader :block

    def initialize(from, to, block)
      raise ArgumentError.new unless from.is_a?(Expression) and
                                     to.is_a?(Expression) and
                                     block.is_a?(Block)
      @from = from
      @to = to
      @block = block
      self.indent = 0      
    end

    def indent=(i)
      @indent = i
      @block.indent = i + 2
    end

    def execute(vm)    
      f = @from.execute(vm)
      t = @to.execute(vm)
      i = BASE_ITERATOR
      while (vm.memory.key?(i))
        i = i.succ
      end

      if f >= t
        f.upto t do |itr|
          vm.inc_counter 2
          vm.memory[i] = itr
          @block.execute(vm)
        end
      else 
        f.downto t do |itr|
          vm.inc_counter 2
          vm.memory[i] = itr
          @block.execute(vm)
        end
      end
      vm.memory.delete(i)
    end

    def to_s
      str_indent = " " * @indent 
      itr = BASE_ITERATOR
      @indent.times do itr = itr.succ end
      "#{@from}.to(@to) do |#{itr}|\n"+
      str_indent + "  #{@block}\n"+
      str_indent + "end"
    end
  end

end
