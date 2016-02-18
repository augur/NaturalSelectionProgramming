#!/usr/bin/env ruby
# encoding: utf-8


:u  #unkind, unreductable operand
4   #constant (reductable) operand (of type int for simplicity)
:+
:-
:*
:/

=begin
	Input looks like [
					  inner_sign_no, //in range 1..2
 					  operand1,
					  sign1,
					  operand2,
					  sign2,
					  operand3
		     		 ]
[+-] and [*/] groups must not be mixed in single input
=end				
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

def commutative?(sign)
	return (sign == :+) || (sign == :*)
end

def rend_result(result)
	"#{result[:result_op1]}#{result[:result_sign]}#{result[:result_op2]}"
end
