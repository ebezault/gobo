﻿note

	description: "[
		Eiffel parenthesis call expressions (call to the feature asociated with 'alias "()").
	]"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2016-2024, Eric Bezault and others"
	license: "MIT License"

class ET_PARENTHESIS_EXPRESSION

inherit

	ET_PARENTHESIS_CALL
		undefine
			parenthesis_call
		redefine
			reset
		end

	ET_QUALIFIED_FEATURE_CALL_EXPRESSION
		redefine
			reset
		end

	ET_CALL_EXPRESSION_WITH_ACTUAL_ARGUMENT_LIST
		undefine
			is_call_agent,
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			is_instance_free,
			reset,
			add_old_expressions,
			add_separate_arguments
		end

create

	make

feature -- Initialization

	reset
			-- Reset call as it was just after it was last parsed.
		do
			precursor {ET_QUALIFIED_FEATURE_CALL_EXPRESSION}
			precursor {ET_PARENTHESIS_CALL}
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_parenthesis_expression (Current)
		end

end
