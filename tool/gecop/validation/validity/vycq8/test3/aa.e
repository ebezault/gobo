class AA

create

	make

feature

	make
		local
			b: BB
			c: CC [STRING]
		do
			create b
			c := b
			print ("Failed")
		end

end
