class AA

create

	make

feature

	make
		local
			b: BB [ANY]
			c: CC
		do
			create b
			c := b
			print ("Failed")
		end

end
