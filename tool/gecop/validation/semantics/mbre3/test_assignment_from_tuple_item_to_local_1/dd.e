expanded class DD

inherit

	CC
		redefine
			copy
		end

feature

	copy (other: like Current)
		do
			value := other.value
			if not {ISE_RUNTIME}.in_assertion then
				print ("DD copied%N")
			end
		end

end
