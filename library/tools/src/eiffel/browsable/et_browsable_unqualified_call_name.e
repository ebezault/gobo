note

	description:

		"Browsable names of unqualified calls"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2025-2026, Eric Bezault and others"
	license: "MIT License"

class ET_BROWSABLE_UNQUALIFIED_CALL_NAME

inherit

	ET_BROWSABLE_UNQUALIFIED_NAME
		redefine
			name
		end

create

	make

feature -- Access

	name: ET_CALL_NAME
			-- AST node corresponding to the name

	call_feature: detachable ET_FEATURE
			-- Feature of the call, if any
		local
			l_seed: INTEGER
		do
			if attached {ET_CALL_NAME} name as l_call_name then
				l_seed := l_call_name.seed
				if l_seed /= 0 then
					Result := current_class.seeded_feature (l_seed)
				end
			end
		end

	type_base_class: detachable ET_CLASS
			-- Base class of the type of the browsable name, if any
		do
			if not attached call_feature as l_feature then
				-- No type definition.
			elseif attached l_feature.type as l_type then
				Result := l_type.base_class (current_class)
			end
		end

feature -- Output

	append_description_to_string (a_string: STRING_8)
			-- Append `description' to `a_string'.
		do
			if attached call_feature as l_feature then
				append_feature_description_to_string (l_feature, a_string)
			end
		end

feature -- Processing

	process (a_processor: ET_BROWSABLE_NAME_PROCESSOR)
			-- Process current name.
		do
			a_processor.process_unqualified_call_name (Current)
		end

end
