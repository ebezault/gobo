class AA

create

	make

feature

	make
		local
			b: BB [INTEGER]
			c: CC
		do
			create b
			c := b
			print ("Failed")
		end

end
