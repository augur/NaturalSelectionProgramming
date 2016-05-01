#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../sorting/sorting_vm"
require_relative "../sorting/sorting_algs_probe"
require "test/unit"


class TestSortingAlgsProbe < Test::Unit::TestCase

  def setup
    @vm = SortingVM::SortingVM.new([6,4,1,2,5,3], 1000)
  end

  def test_bubble
    sort = SortingAlgsProbe.bubble_sort
    puts sort
    @vm.run(sort)
    assert_equal([1,2,3,4,5,6], @vm.result)
    puts @vm.counter
  end

  def test_selection
    sort = SortingAlgsProbe.selection_sort
    puts sort
    @vm.run(sort)
    assert_equal([1,2,3,4,5,6], @vm.result)
    puts @vm.counter
  end
end
