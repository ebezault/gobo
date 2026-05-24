class AA

create

	make

feature

	make
		local
			bc: BB [CC]
			c: CC
			ba: BB [ANY]
			a: ANY
		do
			create c
			create bc.make (c)
			c := bc
			print (c.generating_type)
			print ("%N")
			create a
			create ba.make (a)
			a := ba
			print (a.generating_type)
			print ("%N")
			print ("Failed")
		end

end
