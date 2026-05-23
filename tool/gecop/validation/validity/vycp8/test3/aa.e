class AA

create

	make

feature

	make
		local
			bc: BB [CC]
			c: CC
		do
			create c
			bc := c
			print (bc.generating_type)
			print ("%N")
			print ("Failed")
		end

end
