note

	description:

		"Browsable boolean keywords"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2025-2026, Eric Bezault and others"
	license: "MIT License"

class ET_BROWSABLE_BOOLEAN_KEYWORD

inherit

	ET_BROWSABLE_KEYWORD
		redefine
			name,
			type_base_class,
			append_description_to_string,
			process
		end

create

	make

feature -- Access
	
	name: ET_BOOLEAN_CONSTANT
			-- AST node corresponding to the Boolean keyword

	type_base_class: ET_CLASS
			-- Base class of the type of the browsable name, if any
		do
			Result := current_class.universe.boolean_type.base_class
		ensure then
			type_base_class_not_void: Result /= Void
		end

feature -- Output

	append_description_to_string (a_string: STRING_8)
			-- Append `description' to `a_string'.
		do
			a_string.append_string (name.text)
			a_string.append_character (':')
			a_string.append_character (' ')
			current_class.universe.boolean_type.append_canonical_to_string (a_string)
		end

feature -- Processing

	process (a_processor: ET_BROWSABLE_NAME_PROCESSOR)
			-- Process current name.
		do
			a_processor.process_boolean_keyword (Current)
		end

end
