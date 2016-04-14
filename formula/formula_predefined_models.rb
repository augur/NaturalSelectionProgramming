#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../challenge"
require_relative "formula"

module FormulaPredefinedModels

  # First model describes simple polynom, and should be solved easily
  # x^2 - 8*x + 2.5
  MODEL1 = Challenge::Model.new {|input| input[:x]**2 - 8*input[:x] + 2.5}
  INPUT_GROUP1 = (0...256).map {|i| {:x => i}}  #non-inclusive

  VARS_LIST1 = [:x]
  CASE_GROUP1 = Challenge::build_case_group(MODEL1, INPUT_GROUP1)
  BASE_FORMULA1 = Formula::Variable.new :x

  # Second model is natural log, which can be transformed into Taylor
  # ln(1+x) on input 0..25.5 (0.1 step)
  MODEL2 = Challenge::Model.new {|input| Math.log(1 + input[:x])}
  INPUT_GROUP2 = (0...256).map {|i| {:x => i/10.0}}  #non-inclusive

  VARS_LIST2 = [:x]
  CASE_GROUP2 = Challenge::build_case_group(MODEL2, INPUT_GROUP2)
  BASE_FORMULA2 = Formula::Variable.new :x

  #Third model is sin, which can be also transformed into Taylor
  # sin(x) on input 0..6.28 (0.2 step)
  MODEL3 = Challenge::Model.new {|input| Math.sin(input[:x])}
  INPUT_GROUP3 = (0..314).map {|i| {:x => i/50.0}}

  VARS_LIST3 = [:x]
  CASE_GROUP3 = Challenge::build_case_group(MODEL3, INPUT_GROUP3)
  BASE_FORMULA3 = Formula::Variable.new :x  
end