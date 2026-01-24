note

	description:

		"Null processors of browsable names"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class ET_BROWSABLE_NAME_NULL_PROCESSOR

inherit

	ET_BROWSABLE_NAME_PROCESSOR

create

	make

feature {NONE} -- Initialization

	make
			-- Create a new null processor.
		do
		end

feature {ET_BROWSABLE_NAME} -- Processing

	process_argument_name (a_name: ET_BROWSABLE_ARGUMENT_NAME)
			-- Process `a_name`.
		do
		end

	process_boolean_keyword (a_name: ET_BROWSABLE_BOOLEAN_KEYWORD)
			-- Process `a_name`.
		do
		end

	process_class_name (a_name: ET_BROWSABLE_CLASS_NAME)
			-- Process `a_name`.
		do
		end

	process_current_keyword (a_name: ET_BROWSABLE_CURRENT_KEYWORD)
			-- Process `a_name`.
		do
		end

	process_formal_parameter_name (a_name: ET_BROWSABLE_FORMAL_PARAMETER_NAME)
			-- Process `a_name`.
		do
		end

	process_inline_separate_argument_name (a_name: ET_BROWSABLE_INLINE_SEPARATE_ARGUMENT_NAME)
			-- Process `a_name`.
		do
		end

	process_iteration_item_name (a_name: ET_BROWSABLE_ITERATION_ITEM_NAME)
			-- Process `a_name`.
		do
		end

	process_keyword (a_name: ET_BROWSABLE_KEYWORD)
			-- Process `a_name`.
		do
		end

	process_local_name (a_name: ET_BROWSABLE_LOCAL_NAME)
			-- Process `a_name`.
		do
		end

	process_object_test_local_name (a_name: ET_BROWSABLE_OBJECT_TEST_LOCAL_NAME)
			-- Process `a_name`.
		do
		end

	process_precursor_name (a_name: ET_BROWSABLE_PRECURSOR_NAME)
			-- Process `a_name`.
		do
		end

	process_qualified_call_name (a_name: ET_BROWSABLE_QUALIFIED_CALL_NAME)
			-- Process `a_name`.
		do
		end

	process_result (a_name: ET_BROWSABLE_RESULT)
			-- Process `a_name`.
		do
		end

	process_tuple_label_name (a_name: ET_BROWSABLE_TUPLE_LABEL_NAME)
			-- Process `a_name`.
		do
		end

	process_unqualified_alias_name (a_name: ET_BROWSABLE_UNQUALIFIED_ALIAS_NAME)
			-- Process `a_name`.
		do
		end

	process_unqualified_call_name (a_name: ET_BROWSABLE_UNQUALIFIED_CALL_NAME)
			-- Process `a_name`.
		do
		end

	process_void_keyword (a_name: ET_BROWSABLE_VOID_KEYWORD)
			-- Process `a_name`.
		do
		end

end
