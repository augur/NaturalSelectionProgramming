#!/usr/bin/env ruby
# encoding: utf-8

require_relative "formula"
require_relative "formula_mutation"
require "test/unit"

class TestFormulaMutation < Test::Unit::TestCase
  include FormulaMutator

end