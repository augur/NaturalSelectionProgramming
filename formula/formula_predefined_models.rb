#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../challenge"
require_relative "formula"

module FormulaPredefinedModels

  MODEL0 = Challenge::Model.new {|input| input[:x]**2}
  INPUT_GROUP0 = (0...100).map {|i| {:x => i/10.0}}  #non-inclusive

  VARS_LIST0 = [:x]
  CASE_GROUP0 = Challenge::build_case_group(MODEL0, INPUT_GROUP0)
  BASE_FORMULA0 = Formula::Variable.new :x


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

  #4-variable polynom, each variable in range 0..3, (81 total)
  # 2v + 3x - 4y + 5z - 6
  MODEL4 = Challenge::Model.new {|input| 2*input[:v] + 3*input[:x] -
                                 4*input[:y] + 5*input[:z] - 6}
  INPUT_GROUP4 = []
  (0..3).each do |v|
    (0..3).each do |x|
      (0..3).each do |y|
        (0..3).each do |z|
          INPUT_GROUP4.push({:v => v, :x => x, :y => y, :z => z})
        end
      end
    end
  end

  VARS_LIST4 = [:v, :x, :y, :z]
  CASE_GROUP4 = Challenge::build_case_group(MODEL4, INPUT_GROUP4)
  BASE_FORMULA4 = Formula::Variable.new :x
end
