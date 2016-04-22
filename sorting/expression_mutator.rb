#!/usr/bin/env ruby
# encoding: utf-8

module ExpressionMutator

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
end
