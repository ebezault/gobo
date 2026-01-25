note

	description:

		"Browsable qualified call names"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2025-2026, Eric Bezault and others"
	license: "MIT License"

class ET_BROWSABLE_QUALIFIED_CALL_NAME

inherit

	ET_BROWSABLE_QUALIFIED_NAME

create

	make

feature -- Access

	call_feature: detachable ET_FEATURE
			-- Feature of the call, if any
		local
			l_seed: INTEGER
		do
			l_seed := name.seed
			if l_seed /= 0 then
				Result := target_base_class.seeded_feature (l_seed)
			end
		end

	type_base_class: detachable ET_CLASS
			-- Base class of the type of the browsable name, if any
		local
			l_nested_type_context: ET_NESTED_TYPE_CONTEXT
		do
			if not attached call_feature as l_feature then
				-- No type.
			elseif attached l_feature.type as l_type then
				create l_nested_type_context.make_with_capacity (current_class, 1)
				l_nested_type_context.put_last (target_type)
				Result := l_type.base_class (l_nested_type_context)
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
			a_processor.process_qualified_call_name (Current)
		end

end
