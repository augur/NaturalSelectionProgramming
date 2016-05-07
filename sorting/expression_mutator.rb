#!/usr/bin/env ruby
# encoding: utf-8

require_relative "expression" #circular reference -_-'

module ExpressionMutator

  ### Available variable names pool ###
  def self.vars_pool=(vars)
    @vars_pool = vars
  end

  def self.vars_pool
    @vars_pool 
  end
  #####################################
  ### Available iterator names pool ###
  def self.iterators_pool=(iterators)
    @iterators_pool = iterators
  end

  def self.iterators_pool
    @iterators_pool 
  end
  #####################################


  def mutate
    case self
    when Expression::Expression
      ExpressionMutator::expression_mutate(self)
    when Expression::CommandStruct
      ExpressionMutator::comstruct_mutate(self)
    end
  end

  def self.expression_mutate(e)
    #
  end

  def self.comstruct_mutate(cs)
    #
  end


  def self.random_expression
    #
  end


  ### Random Expressions ###

  def self.random_epsilon
    Expression::Epsilon.new
  end

  def self.random_const
    Expression::Const.new([0, 1].sample)
  end

  def self.random_tsize
    Expression::TSize.new
  end

  def self.random_var
    Expression::Var.new(@vars_pool.sample)
  end

  def self.random_iter
    Expression::Iterator.new(@iterators_pool.sample)
  end

  def self.random_index
    case [:const, :tsize, :var, :iter, :succ, :pred]
    when :const
      return random_const
    when :tsize
      return random_tsize
    when :var
      return random_var
    when :iter
      return random_iter
    when :succ
      return Expression::Succ.new(random_index)
    when :pred
      return Expression::Pred.new(random_index)
    else
      raise "Unreachable case"
    end
  end

end
