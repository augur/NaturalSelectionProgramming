#!/usr/bin/env ruby
# encoding: utf-8

require_relative "formula_mutation"
require_relative "defined_formula_models"
require_relative "evolution"

case_group = DefinedFormulaModels::CASE_GROUP2
base_formula = DefinedFormulaModels::BASE_FORMULA2
FormulaMutator::vars_list = DefinedFormulaModels::VARS_LIST2

rounds_to_win = 512
winners = 64
randoms = 256

evolution = Evolution::FormulaEvolution.new(case_group, base_formula, rounds_to_win, winners, randoms)
evolution.run(0.1)