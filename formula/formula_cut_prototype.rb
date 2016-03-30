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
	inner_sign_no, 
	     operand1,
	        sign1,
	     operand2,
	        sign2,
	     operand3 = input

	result = {
		:result_op1 => nil,
		:result_op2 => nil,
		:result_sign => nil,
	}

	const_1 = nil
	const_2 = nil
	const_sign = nil

	### main algorithm here ###
	if (operand1 == :u)
		const_sign = combined_sign(sign1, sign2)
		const_1 = operand2
		const_2 = operand3

		result[:result_op1]  = operand1
		result[:result_sign] = sign1
		result[:result_op2]  = operate(const_sign, const_1, const_2)
	elsif (operand2 == :u)
		const_1 = operand1
		const_2 = operand3	
		const_sign = (inner_sign_no == 1) ? sign2 : combined_sign(sign1, sign2)

		result[:result_op1]  = operate(const_sign, const_1, const_2)
		result[:result_sign] = sign1
		result[:result_op2]  = operand2
	elsif (operand3 == :u)
		const_sign = sign1
		const_1 = operand1
		const_2 = operand2		

		result[:result_op1]  = operate(const_sign, const_1, const_2)
		result[:result_sign] = combined_sign(sign1, sign2)
		result[:result_op2]  = operand3
	else
		raise "Assertion failed" #should be unreachable
	end
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

def combined_sign(sign1, sign2)
	c1 = commutative?(sign1)
	c2 = commutative?(sign2)
	if c1&&c2
		return sign1 # or sign2, whatever
	elsif not(c1||c2)
		#return inverse sign
		if sign1 == :-
			return :+
		else #it should definitely be :/
			return :*
		end
	else
		#return which is not commutative
		return c1 ? sign2 : sign1	
	end
	return nil #formally unreachable
end

def rend_result(result)
	"#{result[:result_op1]}#{result[:result_sign]}#{result[:result_op2]}"
end
