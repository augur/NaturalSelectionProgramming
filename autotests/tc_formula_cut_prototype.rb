#!/usr/bin/env ruby
# encoding: utf-8

require_relative "../formula_cut_prototype"
require "test/unit"

class TestFormulaCutPrototype < Test::Unit::TestCase
	def test_combined_signs
		assert_equal(:+, combined_sign(:+, :+))
		assert_equal(:-, combined_sign(:-, :+))
		assert_equal(:-, combined_sign(:+, :-))
		assert_equal(:+, combined_sign(:-, :-))
		assert_equal(:*, combined_sign(:*, :*))
		assert_equal(:/, combined_sign(:/, :*))
		assert_equal(:/, combined_sign(:*, :/))
		assert_equal(:*, combined_sign(:/, :/))
	end

	def test_ucc_plus_minus
		#(u + 4) + 2
		assert_equal("u+6", prototype_cut([1, :u, :+, 4, :+, 2]))

		#(u - 4) + 2
		assert_equal("u-2", prototype_cut([1, :u, :-, 4, :+, 2]))

		#(u + 4) - 2
		assert_equal("u+2", prototype_cut([1, :u, :+, 4, :-, 2]))

		#(u - 4) - 2
		assert_equal("u-6", prototype_cut([1, :u, :-, 4, :-, 2]))
	end

	def test_ucc_mult_divide
		#(u * 4) * 2
		assert_equal("u*8", prototype_cut([1, :u, :*, 4, :*, 2]))

		#(u / 4) * 2
		assert_equal("u/2", prototype_cut([1, :u, :/, 4, :*, 2]))

		#(u * 4) / 2
		assert_equal("u*2", prototype_cut([1, :u, :*, 4, :/, 2]))

		#(u / 4) / 2
		assert_equal("u/8", prototype_cut([1, :u, :/, 4, :/, 2]))
	end	

	def test_ccu_plus_minus
		#8 + (4 + u)
		assert_equal("12+u", prototype_cut([2, 8, :+, 4, :+, :u]))

		#8 - (4 + u)
		assert_equal("4-u",  prototype_cut([2, 8, :-, 4, :+, :u]))

		#8 + (4 - u)
		assert_equal("12-u", prototype_cut([2, 8, :+, 4, :-, :u]))

		#8 - (4 - u)
		assert_equal("4+u",  prototype_cut([2, 8, :-, 4, :-, :u]))
	end

	def test_ccu_mult_divide
		#8 * (4 * u)
		assert_equal("32*u", prototype_cut([2, 8, :*, 4, :*, :u]))

		#8 / (4 * u)
		assert_equal("2/u",  prototype_cut([2, 8, :/, 4, :*, :u]))

		#8 * (4 / u)
		assert_equal("32/u", prototype_cut([2, 8, :*, 4, :/, :u]))

		#8 / (4 / u)
		assert_equal("2*u",  prototype_cut([2, 8, :/, 4, :/, :u]))
	end

	def test_cuc1_plus_minus
		#(8 + u) + 2
		assert_equal("10+u", prototype_cut([1, 8, :+, :u, :+, 2]))		

		#(8 - u) + 2
		assert_equal("10-u", prototype_cut([1, 8, :-, :u, :+, 2]))		

		#(8 + u) - 2
		assert_equal("6+u",  prototype_cut([1, 8, :+, :u, :-, 2]))		

		#(8 - u) - 2
		assert_equal("6-u",  prototype_cut([1, 8, :-, :u, :-, 2]))		
	end

	def test_cuc1_mult_divide
		#(8 * u) * 2
		assert_equal("16*u", prototype_cut([1, 8, :*, :u, :*, 2]))		

		#(8 / u) * 2
		assert_equal("16/u", prototype_cut([1, 8, :/, :u, :*, 2]))		

		#(8 * u) / 2
		assert_equal("4*u",  prototype_cut([1, 8, :*, :u, :/, 2]))		

		#(8 / u) / 2
		assert_equal("4/u",  prototype_cut([1, 8, :/, :u, :/, 2]))		
	end	

	def test_cuc2_plus_minus
		#8 + (u + 2)
		assert_equal("10+u", prototype_cut([2, 8, :+, :u, :+, 2]))		

		#8 - (u + 2)
		assert_equal("6-u",  prototype_cut([2, 8, :-, :u, :+, 2]))		

		#8 + (u - 2)
		assert_equal("6+u",  prototype_cut([2, 8, :+, :u, :-, 2]))		

		#8 - (u - 2)
		assert_equal("10-u", prototype_cut([2, 8, :-, :u, :-, 2]))		
	end

	def test_cuc2_mult_divide
		#8 * (u * 2)
		assert_equal("16*u", prototype_cut([2, 8, :*, :u, :*, 2]))		

		#8 / (u * 2)
		assert_equal("4/u",  prototype_cut([2, 8, :/, :u, :*, 2]))		

		#8 * (u / 2)
		assert_equal("4*u",  prototype_cut([2, 8, :*, :u, :/, 2]))		

		#8 / (u / 2)
		assert_equal("16/u", prototype_cut([2, 8, :/, :u, :/, 2]))		
	end	
end
