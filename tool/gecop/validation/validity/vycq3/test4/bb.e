class BB [G -> ANY]

inherit

	CC [INTEGER]

convert

	f: {CC [G]}

feature

	f: CC [G]
		do
			create Result
		end

end
