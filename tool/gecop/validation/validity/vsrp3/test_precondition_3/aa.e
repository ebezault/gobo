class AA

create

	make

feature
	
	make
		require
			f
		do
			print ("Failed")
		end

	f: BOOLEAN
		do
			Result := True
		end

end