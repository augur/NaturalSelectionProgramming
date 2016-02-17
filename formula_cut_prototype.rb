#!/usr/bin/env ruby
# encoding: utf-8


:br #bracket
:u  #unkind, unreductable operand
4   #constant operand (of type int for simplicity)
:+
:-
:*
:/

def prototype_cut(input)
	result = {
		:result_op1 => nil,
		:result_op2 => nil,
		:result_sign => nil,
		:const1 => nil,
		:const2 => nil,
		:const_sign => nil
	}
	### main algorithm here ###



	###########################
	return rend_result(result)
end

### helper funcs ###

def operate(sign, const1, const2)
	case sign
	when :+
		return const1 + const2
	when :-
		return const1 - const2
	when :*
		return const1 * const2
	when :/
		return const1 / const2
	end
end

op_group1 = [:+, :-]
op_group2 = [:*, :/]

def combines?(sign1, sign2)
	return (op_group1.include?(sign1) && op_group1.include?(sign2))||
	(op_group2.include?(sign1) && op_group2.include?(sign2))
end

def commutative?(sign)
	return (sign == :+) || (sign == :*)
end

def rend_result(result)
	"#{result[:result_op1]}#{result[:result_sign]}#{result[:result_op2]}"
end
