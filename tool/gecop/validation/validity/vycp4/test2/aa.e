class AA

create

	make

feature

	make
		local
			b: BB
			c1: CC [STRING]
			c2: CC [INTEGER]
		do
			create c1
			b := c1
			create c2
			b := c1
			print ("Failed")
		end

end
