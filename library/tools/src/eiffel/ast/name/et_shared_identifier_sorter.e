note

	description:

		"Shared identifier sorters"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class ET_SHARED_IDENTIFIER_SORTER

inherit

	ET_SHARED_IDENTIFIER_COMPARATOR

feature -- Access

	identifier_sorter: DS_QUICK_SORTER [ET_IDENTIFIER]
			-- Identifier sorter
		once
			create Result.make (identifier_comparator)
		ensure
			instance_free: class
			identifier_sorter_not_void: Result /= Void
		end

end
