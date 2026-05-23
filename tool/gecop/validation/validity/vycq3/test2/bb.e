class BB [G -> ANY]

inherit

	CC [INTEGER]

convert

	f: {CC [INTEGER]}

feature

	f: CC [INTEGER]
		do
			create Result
		end

end
