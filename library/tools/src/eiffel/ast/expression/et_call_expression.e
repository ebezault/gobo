﻿note

	description:

		"Eiffel call expressions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2024, Eric Bezault and others"
	license: "MIT License"

deferred class ET_CALL_EXPRESSION

inherit

	ET_REGULAR_FEATURE_CALL
		redefine
			name,
			parenthesis_call
		end

	ET_FEATURE_CALL_EXPRESSION
		redefine
			name,
			parenthesis_call
		end

	ET_CALL_EXPRESSION_WITH_ACTUAL_ARGUMENT_LIST
		undefine
			is_call_agent,
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			is_instance_free,
			add_old_expressions
		end

	ET_CHOICE_CONSTANT
		undefine
			reset,
			is_instance_free,
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			add_old_expressions
		end

feature -- Access

	name: ET_FEATURE_NAME
			-- Feature name
		deferred
		end

	parenthesis_call: detachable ET_PARENTHESIS_EXPRESSION
			-- <Precursor>

feature -- Setting

	set_parenthesis_call (a_target: ET_EXPRESSION; a_name: ET_PARENTHESIS_SYMBOL; a_arguments: ET_ACTUAL_ARGUMENT_LIST)
			-- Set `parenthesis_call' with `a_target', `a_name' and `a_arguments'.
		do
			create parenthesis_call.make (a_target, a_name, a_arguments)
		end

end
