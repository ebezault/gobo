note

	description:

		"Processors of types of browsable names"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

deferred class ET_BROWSABLE_NAME_TYPE_PROCESSOR

inherit

	ET_BROWSABLE_NAME_PROCESSOR

feature -- Processing

	process_class (a_class: ET_CLASS; a_browsable_name: ET_BROWSABLE_NAME)
			-- Process `a_class` which is the base class of the type of
			-- the Eiffel symbol `a_browsable_name`.
		require
			a_class_not_void: a_class /= Void
			a_browsable_name_not_void: a_browsable_name /= Void
		deferred
		end

	process_formal_parameter (a_formal_parameter: ET_FORMAL_PARAMETER; a_browsable_name: ET_BROWSABLE_NAME)
			-- Process `a_formal_parameter` which is the type of
			-- the Eiffel symbol `a_browsable_name`.
		require
			a_formal_parameter_not_void: a_formal_parameter /= Void
			a_browsable_name_not_void: a_browsable_name /= Void
		deferred
		end

feature {ET_BROWSABLE_NAME} -- Processing

	process_argument_name (a_name: ET_BROWSABLE_ARGUMENT_NAME)
			-- Process `a_name`.
		do
			if attached a_name.type_base_class as l_base_class then
				process_class (l_base_class, a_name)
			end
		end

	process_boolean_keyword (a_name: ET_BROWSABLE_BOOLEAN_KEYWORD)
			-- Process `a_name`.
		do
			process_class (a_name.type_base_class, a_name)
		end

	process_class_name (a_name: ET_BROWSABLE_CLASS_NAME)
			-- Process `a_name`.
		do
			process_class (a_name.type_base_class, a_name)
		end

	process_current_keyword (a_name: ET_BROWSABLE_CURRENT_KEYWORD)
			-- Process `a_name`.
		do
			process_class (a_name.type_base_class, a_name)
		end

	process_formal_parameter_name (a_name: ET_BROWSABLE_FORMAL_PARAMETER_NAME)
			-- Process `a_name`.
		do
			process_formal_parameter (a_name.formal_parameter, a_name)
		end

	process_inline_separate_argument_name (a_name: ET_BROWSABLE_INLINE_SEPARATE_ARGUMENT_NAME)
			-- Process `a_name`.
		do
			process_class (a_name.type_base_class, a_name)
		end

	process_iteration_item_name (a_name: ET_BROWSABLE_ITERATION_ITEM_NAME)
			-- Process `a_name`.
		do
			process_class (a_name.type_base_class, a_name)
		end

	process_keyword (a_name: ET_BROWSABLE_KEYWORD)
			-- Process `a_name`.
		do
		end

	process_local_name (a_name: ET_BROWSABLE_LOCAL_NAME)
			-- Process `a_name`.
		do
			if attached a_name.type_base_class as l_base_class then
				process_class (l_base_class, a_name)
			end
		end

	process_object_test_local_name (a_name: ET_BROWSABLE_OBJECT_TEST_LOCAL_NAME)
			-- Process `a_name`.
		do
			process_class (a_name.type_base_class, a_name)
		end

	process_precursor_name (a_name: ET_BROWSABLE_PRECURSOR_NAME)
			-- Process `a_name`.
		do
			if attached a_name.type_base_class as l_base_class then
				process_class (l_base_class, a_name)
			end
		end

	process_qualified_call_name (a_name: ET_BROWSABLE_QUALIFIED_CALL_NAME)
			-- Process `a_name`.
		do
			if attached a_name.type_base_class as l_base_class then
				process_class (l_base_class, a_name)
			end
		end

	process_result (a_name: ET_BROWSABLE_RESULT)
			-- Process `a_name`.
		do
			if attached a_name.type_base_class as l_base_class then
				process_class (l_base_class, a_name)
			end
		end

	process_tuple_label_name (a_name: ET_BROWSABLE_TUPLE_LABEL_NAME)
			-- Process `a_name`.
		do
			if attached a_name.type_base_class as l_base_class then
				process_class (l_base_class, a_name)
			end
		end

	process_unqualified_alias_name (a_name: ET_BROWSABLE_UNQUALIFIED_ALIAS_NAME)
			-- Process `a_name`.
		do
			if attached a_name.type_base_class as l_base_class then
				process_class (l_base_class, a_name)
			end
		end

	process_unqualified_call_name (a_name: ET_BROWSABLE_UNQUALIFIED_CALL_NAME)
			-- Process `a_name`.
		do
			if attached a_name.type_base_class as l_base_class then
				process_class (l_base_class, a_name)
			end
		end

	process_void_keyword (a_name: ET_BROWSABLE_VOID_KEYWORD)
			-- Process `a_name`.
		do
			process_class (a_name.type_base_class, a_name)
		end

end
