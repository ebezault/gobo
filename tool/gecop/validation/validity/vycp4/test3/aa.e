class AA

create

	make

feature

	make
		local
			b: BB [INTEGER]
			c: CC [INTEGER]
		do
			create c
			b := c
			print ("Failed")
		end

end
