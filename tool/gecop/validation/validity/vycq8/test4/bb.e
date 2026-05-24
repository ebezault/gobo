class BB [G -> ANY]

create

	make

convert

	f: {G}

feature

	make (a: G)
		do
			attr := a
		end

	f: G
		do
			Result := attr
		end

	attr: G

end
