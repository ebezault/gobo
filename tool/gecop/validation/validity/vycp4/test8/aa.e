class AA

create

	make

feature

	make
		local
			b: BB
			c: CC
			d: DD
		do
			create c
			b := c
			create d
			b := d
			print ("Passed")
		end

end
