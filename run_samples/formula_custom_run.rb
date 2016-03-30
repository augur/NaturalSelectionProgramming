#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../formula/defined_formula_models"
require_relative "../formula/challenge_formula"
require_relative "../formula/evolution_formula"

unless ARGV.size == 5
  puts "Usage: ruby formula_custom_run.rb <predefined_model_number> <winners> <randoms> <rounds_to_win> <epsilon>"
  exit
end

case_group = DefinedFormulaModels.const_get("CASE_GROUP"+ARGV[0].to_s)
base_formula = DefinedFormulaModels.const_get("BASE_FORMULA"+ARGV[0].to_s)

winners = ARGV[1].to_i
randoms = ARGV[2].to_i
rounds_to_win = ARGV[3].to_i

#Yep, it is dirty hack
ChallengeFormula.const_set("RESULT_EPSILON", ARGV[4].to_f)

e = EvolutionFormula::FormulaEvolution.new(case_group, base_formula, rounds_to_win, winners, randoms)
e.run(0.1)