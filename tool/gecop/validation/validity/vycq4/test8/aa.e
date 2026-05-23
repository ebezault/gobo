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
			create b
			c := b
			d := b
			print ("Passed")
		end

end
