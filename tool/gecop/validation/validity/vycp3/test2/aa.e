class AA

create

	make

feature

	make
		local
			b: BB [ANY]
			c: CC [INTEGER]
		do
			create c
			b := c
			print ("Failed")
		end

end
