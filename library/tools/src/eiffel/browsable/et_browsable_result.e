note

	description:

		"Browsable function results"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2025-2026, Eric Bezault and others"
	license: "MIT License"

class ET_BROWSABLE_RESULT

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

	name: ET_RESULT
			-- AST node corresponding to the Result

	type_base_class: detachable ET_CLASS
			-- Base class of the type of the browsable name, if any
		do
			if attached current_closure as l_closure and then attached l_closure.type as l_type then
				Result := l_type.base_class (current_class)
			end
		end

feature -- Output

	append_description_to_string (a_string: STRING_8)
			-- Append `description' to `a_string'.
		do
			if attached current_closure as l_closure and then attached l_closure.type as l_type then
				a_string.append_string (tokens.result_keyword.text)
				a_string.append_character (':')
				a_string.append_character (' ')
				l_type.named_type_with_type_mark (tokens.detachable_keyword, current_class).append_canonical_with_leading_type_mark_to_string (a_string)
			end
		end

feature -- Processing

	process (a_processor: ET_BROWSABLE_NAME_PROCESSOR)
			-- Process current name.
		do
			a_processor.process_result (Current)
		end

end
