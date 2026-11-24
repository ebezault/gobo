expanded class CC

inherit

	ANY
		redefine
			copy
		end

feature
		
	value: INTEGER
	
	set_value (i: INTEGER)
		do
			value := i
		end

	copy (other: like Current)
		do
			value := other.value
			if not {ISE_RUNTIME}.in_assertion then
				print ("CC copied%N")
			end
		end
		
end
