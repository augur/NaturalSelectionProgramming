#!/usr/bin/env ruby
# encoding: utf-8

require_relative "challenge"
require "test/unit"

class TestChallenge < Test::Unit::TestCase
  def test_model
    assert_raise(ArgumentError) do
      m = Challenge::Model.new
    end

    assert_raise(ArgumentError) do
      m = Challenge::Model.new {}
    end

    m = Challenge::Model.new {|x| x + 1}
    assert_equal(3, m.get_model_result(2))
  end

  def test_case
    c = Challenge::Case.new 2, 3
    assert_equal(2, c.input)
    assert_equal(3, c.model_result)
  end
end
