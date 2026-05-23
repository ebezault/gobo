class AA

create

	make

feature

	make
		local
			b: BB
			c: CC [INTEGER]
		do
			create b
			c := b
			print ("Passed")
		end

end
