#!/usr/bin/env ruby
# encoding: utf-8

require_relative "expression"
require_relative "sorting_vm"

module SortingAlgsProbe

  #Bubble Sort
  #based on python implementation from wikipedia.org
  #def bubble_sort(a):
  #    for i in reversed(range(len(a))):
  #        for j in range(1, i + 1):
  #            if a[j-1] > a[j]:
  #                a[j], a[j-1] = a[j-1], a[j]
  def self.bubble_sort
    zeroConst = Expression::Const.new(0)
    oneConst = Expression::Const.new(1)
    len = Expression::TSize.new
    lenMinusOne= Expression::Pred.new(len)
    iterator_I = Expression::Iterator.new(:i)
    iterator_J = Expression::Iterator.new(:j)
    iterator_J_pred = Expression::Pred.new(iterator_J)
    nilExpr = Expression::Epsilon.new
    nilBlock = Expression::Block.new(nilExpr)
    result_J = Expression::Element.new(iterator_J)
    result_J_pred = Expression::Element.new(iterator_J_pred)

    swap = Expression::Swap.new(iterator_J, iterator_J_pred)
    cond = Expression::Bigger.new(result_J_pred, result_J)
    innerIf = Expression::If.new(cond, swap, nilBlock)
    innerBlock = Expression::Block.new(innerIf)
    innerFor = Expression::Upto.new(oneConst, iterator_I, innerBlock)
    outerBlock = Expression::Block.new(innerFor)
    outerFor = Expression::Downto.new(lenMinusOne, zeroConst, outerBlock);

    bubbleSortCode = Expression::Block.new(outerFor)
    return bubbleSortCode
  end

  #Selection Sort
  #based on java implementation from wikipedia.org
  #public static void sort (int[] arr) {
  #  for (int min=0;min<arr.length-1;min++) {
  #    int least = min;
  #    for (int j=min+1;j<arr.length;j++) {
  #        if(arr[j] < arr[least]) {
  #        least = j;
  #      }
  #    }
  #    int tmp = arr[min];
  #    arr[min] = arr[least];
  #    arr[least] = tmp;
  #  }
  #}
  def self.selection_sort
    zeroConst = Expression::Const.new(0)
    len = Expression::TSize.new
    lenMinusOne= Expression::Pred.new(len)
    lenMinusTwo= Expression::Pred.new(lenMinusOne)

    leastVar = Expression::Var.new(:least)
    iterator_I = Expression::Iterator.new(:i)
    iterator_J = Expression::Iterator.new(:j)
    result_J = Expression::Element.new(iterator_J)
    iterator_I_Succ = Expression::Succ.new(iterator_I)
    leastInit = Expression::Assign.new(leastVar, iterator_I)
    swap = Expression::Swap.new(iterator_I, leastVar)
    nilExpr = Expression::Epsilon.new
    nilBlock = Expression::Block.new(nilExpr)
    result_least = Expression::Element.new(leastVar)
    cond = Expression::Lesser.new(result_J, result_least)

    leastAssign = Expression::Assign.new(leastVar, iterator_J)
    ifBlock = Expression::Block.new(leastAssign)
    innerIf = Expression::If.new(cond, ifBlock, nilBlock)
    innerBlock = Expression::Block.new(innerIf)
    innerFor = Expression::Upto.new(iterator_I_Succ, lenMinusOne, innerBlock)
    outerBlock = Expression::Block.new(leastInit, innerFor, swap)
    outerFor = Expression::Upto.new(zeroConst, lenMinusTwo, outerBlock)

    selectionSortCode = Expression::Block.new(outerFor)
    return selectionSortCode
  end

end
