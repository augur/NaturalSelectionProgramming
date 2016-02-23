#!/usr/bin/env ruby
# encoding: utf-8

#This could be part of formula.rb, but formed into separate file for clarity reasons.

require_relative "formula"

module FormulaCut

  def self.cut(binary_op)
    nil
  end

  ### helper funcs ###

  #Arguments are meant to be subclasses of Formula::BinaryOperator
  def combined_operator_class(operator1_class, operator2_class)
    return nil unless operator1_class.combines_with(operator2_class)
    
    com1 = operator1_class.commutative?
    com2 = operator2_class.commutative?
    if (com1 && com2) #both commutative
      return operator1_class #or operator2_class, whatever
    elsif not(com1 || com2) #both non-commutative
      return operator1_class.inverse_operator
    else #one non-commutative, return it
      return com1 ? operator2_class : operator1_class
    end
  end
end
