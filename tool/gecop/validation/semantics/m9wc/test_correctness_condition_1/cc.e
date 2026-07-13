class CC

create

	make

feature

	make (a: separate BB)
		do
			b := a
		end

	b: separate BB

	f
		do
			{EXECUTION_ENVIRONMENT}.sleep (1_000_000_000)
			separate b as bb do
				bb.set_value (10)
			end
		end

end