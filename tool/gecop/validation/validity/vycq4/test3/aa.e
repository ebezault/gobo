class AA

create

	make

feature

	make
		local
			b: BB [INTEGER]
			c: CC [INTEGER]
		do
			create b
			c := b
			print ("Failed")
		end

end
