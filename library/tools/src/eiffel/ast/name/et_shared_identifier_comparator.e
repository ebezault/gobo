note

	description:

		"Shared identifier comparators"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class ET_SHARED_IDENTIFIER_COMPARATOR

feature -- Access

	identifier_comparator: ET_IDENTIFIER_COMPARATOR
			-- Identifier comparator
		once
			create Result.make
		ensure
			instance_free: class
			identifier_comparator_not_void: Result /= Void
		end

end
