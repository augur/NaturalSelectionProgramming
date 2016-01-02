#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'mutation'

BASE_POTENCY = 5

class Species
  
  attr_reader :ancestor
  attr_reader :code
  attr_reader :generation

  attr_accessor :efficiency
  
  def initialize(ancestor, code)
    @ancestor = ancestor
    @code = code
    @generation = @ancestor.nil? ? 1 : @ancestor.generation + 1
  end

  def spawn_child()
    child = Species.new self, mutate_code
    return child
  end
  
  private
  
  def mutate_code()
    return mutate_Formula(@code)
  end
  
end
