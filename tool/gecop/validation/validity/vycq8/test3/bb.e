class BB

convert

	f: {CC [like g]}

feature

	g: STRING
		do
			Result := "Gobo"
		end

	f: CC [like g]
		do
			create Result
		end

end
