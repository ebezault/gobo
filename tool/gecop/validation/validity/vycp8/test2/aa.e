class AA

create

	make

feature

	make
		local
			b: BB
			c: CC [STRING]
		do
			create c
			b := c
			print ("Failed")
		end

end
