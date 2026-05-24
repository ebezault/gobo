class BB [G -> ANY]

inherit

	CC

convert

	f: {CC}

feature

	f: CC
		do
			create Result
		end

end
