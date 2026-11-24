expanded class CC

inherit

	BB
		redefine
				copy
		end

feature

	copy (other: like Current)
		do
			value := other.value
			if not {ISE_RUNTIME}.in_assertion then
				print ("CC copied%N")
			end
		end
		
end
