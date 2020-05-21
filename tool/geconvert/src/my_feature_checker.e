note

	description:

		"Eiffel feature validity checkers"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2020, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class MY_FEATURE_CHECKER

inherit

	ET_FEATURE_CHECKER
		redefine
			convert_expression
		end

create

	make

feature -- Status report

	has_string_convert: BOOLEAN
			-- Have implicit conversions between [READABLE_]STRING_32 and [READABLE_]STRING_8 been found?

feature -- Status setting

	set_has_string_convert (b: BOOLEAN)
			-- Set `has_string_convert` to `b`.
		do
			has_string_convert := b
		ensure
			has_string_convert_set: has_string_convert = b
		end

feature {NONE} -- Conversion

	convert_expression (a_source: ET_EXPRESSION; a_source_type, a_target_type: ET_NESTED_TYPE_CONTEXT): detachable ET_CONVERT_EXPRESSION
			-- <Precursor>
		do
			Result := precursor (a_source, a_source_type, a_target_type)
			if attached {ET_CONVERT_TO_EXPRESSION} Result as l_convert_to then
				if
					attached current_universe.master_class_by_name ("READABLE_STRING_32") as l_readable_string_32 and then
					a_source_type.conforms_to_type_with_type_marks (l_readable_string_32.actual_class, tokens.attached_separate_type_mark, current_type, tokens.attached_separate_type_mark, system_processor) and then
					attached current_universe.master_class_by_name ("READABLE_STRING_8") as l_readable_string_8 and then
					a_target_type.conforms_to_type_with_type_marks (l_readable_string_8.actual_class, tokens.attached_separate_type_mark, current_type, tokens.attached_separate_type_mark, system_processor)
				then
					create {MY_CONVERT_TO_EXPRESSION} Result.make (Result.expression, Result.convert_feature)
					has_string_convert := True
				end
			end
		end

end
