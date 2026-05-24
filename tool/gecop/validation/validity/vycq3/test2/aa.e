class AA

create

	make

feature

	make
		local
			b: BB [ANY]
			c: CC [INTEGER]
		do
			create b
			c := b
			print ("Failed")
		end

end
