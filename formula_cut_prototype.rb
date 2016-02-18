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
	### main algorithm here ###
	if (operand1 == :u)
		result[:result_op1] = operand1
		result[:result_sign] = sign1
		result[:result_op2] = operate(combined_sign(sign1, sign2), operand2, operand3)
	end
	if (operand3 == :u)
		result[:result_op1] = operate(sign1, operand1, operand2)
		result[:result_sign] = combined_sign(sign1, sign2)
		result[:result_op2] = operand3
	end
	if (operand2 == :u)
		result[:result_sign] = sign1
		result[:result_op2] = operand2
		if (inner_sign_no == 1)
			result[:result_op1] = operate(sign2, operand1, operand3)
		else
			result[:result_op1] = operate(combined_sign(sign1, sign2), operand1, operand3)
		end
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
