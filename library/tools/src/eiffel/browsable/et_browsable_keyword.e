note

	description:

		"Browsable keywords"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2025-2026, Eric Bezault and others"
	license: "MIT License"

class ET_BROWSABLE_KEYWORD

inherit

	ET_BROWSABLE_UNQUALIFIED_NAME
		redefine
			name
		end

create

	make

feature -- Access

	name: ET_KEYWORD
			-- AST node corresponding to the Result

	type_base_class: detachable ET_CLASS
			-- Base class of the type of the browsable name, if any
		do
			-- Result := Void
		end

feature -- Output

	append_description_to_string (a_string: STRING_8)
			-- Append `description' to `a_string'.
		do
		end

feature -- Processing

	process (a_processor: ET_BROWSABLE_NAME_PROCESSOR)
			-- Process current name.
		do
			a_processor.process_keyword (Current)
		end

end
