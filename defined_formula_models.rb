#!/usr/bin/env ruby
# encoding: utf-8

require_relative "challenge"
require_relative "formula"

module DefinedFormulaModels

  # First model describes simple polynom, and should be solved easily
  # x^2 - 8*x + 2.5
  MODEL1 = Challenge::Model.new {|input| input[:x]**2 - 8*input[:x] + 2.5}
  INPUT_GROUP1 = (0...1000).map {|i| {:x => i}}  #non-inclusive

  VARS_LIST1 = [:x]
  CASE_GROUP1 = Challenge::build_case_group(MODEL1, INPUT_GROUP1)
  BASE_FORMULA1 = Formula::Variable.new :x

end