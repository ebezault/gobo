class BB

inherit

	CC [ANY]

convert

	f: {CC [INTEGER]}

feature

	f: CC [INTEGER]
		do
			create Result
		end

end
