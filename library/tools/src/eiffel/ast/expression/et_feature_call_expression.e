﻿note

	description:

		"Eiffel feature call expressions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2005-2024, Eric Bezault and others"
	license: "MIT License"

deferred class ET_FEATURE_CALL_EXPRESSION

inherit

	ET_FEATURE_CALL
		redefine
			parenthesis_call
		end

	ET_CALL_EXPRESSION_WITH_ACTUAL_ARGUMENTS
		undefine
			is_call_agent,
			is_instance_free,
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			add_old_expressions
		end

feature -- Access

	parenthesis_call: detachable ET_PARENTHESIS_EXPRESSION
			-- <Precursor>
		do
		end

end
