#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'challenge'

module DefinedFormulaModels

  # First model describes simple polynom, and should be solved easily
  # x^2 - 8*x + 2.5
  MODEL1 = Challenge::Model.new {|input| input[:x]**2 - 8*input[:x] + 2.5}

  INPUT_GROUP1 = (0...1000).map {|i| {:x => i}}  #non-inclusive
  CASE_GROUP1 = Challenge::build_case_group(MODEL1, INPUT_GROUP1)
end