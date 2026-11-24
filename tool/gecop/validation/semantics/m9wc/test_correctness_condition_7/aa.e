class AA

create

	make

feature
		
	make
		local
			b: separate BB
		do
			create b.make
			f (b)
		end

	f (b: detachable separate BB)
		require
			foo: not attached b
		do
			print ("Failed")
		end

end
