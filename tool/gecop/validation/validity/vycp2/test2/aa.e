class AA

create

	make

feature

	make
		local
			b: BB
			c: CC [INTEGER]
		do
			create c
			b := c
			print ("Failed")
		end

end
