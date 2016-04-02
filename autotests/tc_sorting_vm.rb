#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../sorting/sorting_vm"
require "test/unit"

class TestSortingVM < Test::Unit::TestCase

  def test_init
    svm = SortingVM::SortingVM.new([0, 2, 1], 10)
    assert_equal([0,2,1], svm.target)
    assert_equal(10, svm.operation_limit)
  end
  
end
