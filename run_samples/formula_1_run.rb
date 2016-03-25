#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../formula_mutation"
require_relative "../defined_formula_models"
require_relative "../evolution"

case_group = DefinedFormulaModels::CASE_GROUP1
base_formula = DefinedFormulaModels::BASE_FORMULA1
FormulaMutator::vars_list = DefinedFormulaModels::VARS_LIST1

rounds_to_win = 64
winners = 32
randoms = 128

evolution = Evolution::FormulaEvolution.new(case_group, base_formula, rounds_to_win, winners, randoms)
evolution.run(0.1)