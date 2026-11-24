class AA

create

	make

feature
		
	make
		local
			b: separate BB
		do
			create b.make
			b := Void
			f (b)
		end

	f (b: detachable separate BB)
		require
			foo: attached b
		do
			print ("Failed")
		end

end
