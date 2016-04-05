#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../sorting/sorting_vm"
require "test/unit"

class TestSortingVM < Test::Unit::TestCase

  def setup
    @svm = SortingVM::SortingVM.new([0, 2, 1], 10)
  end

  def teardown
    @svm = nil
  end

  def test_init
    assert_equal([0,2,1], @svm.target)
    assert_equal(10, @svm.operation_limit)
  end

  def test_swap_elements
    @svm.run([])
    @svm.swap_elements(1,2)
    assert_equal(2, @svm.target[1])
    assert_equal(1, @svm.target[2])
    
    assert_equal(1, @svm.result[1])
    assert_equal(2, @svm.result[2])
  end

  def test_inc_counter
    @svm.run([])
    @svm.inc_counter(3)
    assert_equal(3, @svm.counter)
  end

  def test_limit_error
    @svm.run([])
    assert_raise(SortingVM::OperationLimitError) do
      11.times { @svm.inc_counter }
    end
  end

  class TestCode
    def execute(vm)
      vm.swap_elements(0, 1)
      vm.inc_counter(3)
    end
  end

  def test_run
    @svm.run([TestCode.new])
    assert_equal([2,0,1], @svm.result)
    assert_equal(3, @svm.counter)
  end
  
end
