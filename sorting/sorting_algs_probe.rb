#!/usr/bin/env ruby
# encoding: utf-8

require_relative "expression"
require_relative "sorting_vm"

#based on python implementation from wikipedia.org
#def bubble_sort(a):
#    for i in reversed(range(len(a))):
#        for j in range(1, i + 1):
#            if a[j-1] > a[j]:
#                a[j], a[j-1] = a[j-1], a[j]

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

puts outerFor

bubbleSortCode = outerFor

vm = SortingVM::SortingVM.new([3,6,4,5,8,9,2,1,7], 1000)
vm.run(bubbleSortCode)
puts vm.counter
puts vm.result
