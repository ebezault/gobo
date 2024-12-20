﻿note

	description:

		"Eiffel expressions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2024, Eric Bezault and others"
	license: "MIT License"

deferred class ET_EXPRESSION

inherit

	ET_EXPRESSION_ITEM
		rename
			expression as expression_item
		end

	ET_CONDITIONAL
		rename
			expression as expression_item
		end

	ET_UNTAGGED_ASSERTION
		rename
			expression as expression_item
		undefine
			reset
		end

	ET_ACTUAL_ARGUMENTS
		rename
			count as actual_argument_count,
			is_empty as is_empty_actual_argument,
			valid_index as valid_index_actual_argument
		undefine
			is_instance_free
		redefine
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			add_old_expressions
		end

	ET_ARGUMENT_OPERAND
		redefine
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			add_old_expressions
		end

	ET_AGENT_ARGUMENT_OPERAND
		undefine
			reset
		redefine
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			add_old_expressions
		end

	ET_TARGET_OPERAND
		undefine
			reset
		redefine
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			add_old_expressions
		end

	ET_AGENT_TARGET
		undefine
			reset
		redefine
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			add_old_expressions
		end

feature -- Access

	actual_argument (i: INTEGER): ET_EXPRESSION
			-- Actual argument at index `i'
		do
			Result := Current
		ensure then
			definition: Result = Current
		end

	expression_item: ET_EXPRESSION
			-- Current expression
		do
			Result := Current
		ensure then
			definition: Result = Current
		end

	unparenthesized_expression: ET_EXPRESSION
			-- Version of current expression without any surrounding parentheses
		do
			Result := Current
		ensure
			unparenthezized_expression_not_void: Result /= Void
		end

feature -- Status report

	is_never_void: BOOLEAN
			-- Can current expression never be void?
		do
			-- Result := False
		end

	is_false: BOOLEAN
			-- Is current expression the 'False' entity (possibly parenthesized)?
		do
			-- Result := False
		end

	is_true: BOOLEAN
			-- Is current expression the 'True' entity (possibly parenthesized)?
		do
			-- Result := False
		end

	is_prefix_expression: BOOLEAN
			-- Is current expression a prefix expression?
		do
			-- Result := False
		end

	has_result: BOOLEAN
			-- Does the entity 'Result' appear in current expression
			-- or (recursively) in one of its subexpressions?
		do
			-- Result := False
		end

	has_address_expression: BOOLEAN
			-- Does an address expression appear in current expression
			-- or (recursively) in one of its subexpressions?
		do
			-- Result := False
		end

	has_agent: BOOLEAN
			-- Does an agent appear in current expression
			-- or (recursively) in one of its subexpressions?
		do
			-- Result := False
		end

	has_typed_object_test: BOOLEAN
			-- Does a typed object-test appear in current expression
			-- or (recursively) in one of its subexpressions?
		do
			-- Result := False
		end

feature -- Measurement

	actual_argument_count: INTEGER = 1
			-- Number of actual arguments

feature -- Type conversion

	manifest_constant_convert_feature (a_source_type: ET_TYPE_CONTEXT; a_target_type: ET_TYPE_CONTEXT; a_universe: ET_UNIVERSE): detachable ET_CONVERT_FEATURE
			-- Implicit feature to convert `Current' of type `a_source_type' to `a_target_type'.
			-- This is only possible when `Current' is a manifest constant with no explicit
			-- type cast and the value of the constant can be represented in `a_target_type'.
			-- Void if no such feature or when not possible.
		require
			a_source_type_not_void: a_source_type /= Void
			a_source_context_valid: a_source_type.is_valid_context
			a_target_type_not_void: a_target_type /= Void
			a_target_context_valid: a_target_type.is_valid_context
			a_universe_not_void: a_universe /= Void
			-- no_cycle: no cycle in anchored types involved.
		do
			-- Result := Void
		end

feature -- Assertions

	add_old_expressions (a_list: DS_ARRAYED_LIST [ET_OLD_EXPRESSION])
			-- Add to `a_list' all old expressions appearing in current expression
			-- and (recursively) in its subexpressions.
		do
		end

feature -- SCOOP

	add_separate_arguments (a_list: DS_ARRAYED_LIST [ET_IDENTIFIER]; a_closure: ET_CLOSURE)
			-- Add to `a_list' inline separate arguments or formal arguments which
			-- when controlled (i.e. when their type is separate) implies that when
			-- the current expression is involved in the target of a separate call
			-- this target is also controlled.
			-- `a_closure' is the closure (i.e. inline agent or enclosing feature)
			-- in which the current expression appears.
			-- (Used when determining the SCOOP sessions to be used when recording
			-- a separate call to another SCOOP processor.)
		require
			a_list_not_void: a_list /= Void
			no_void_item: not a_list.has_void
			a_closure_not_void: a_closure /= Void
			valid_items: across a_list as l_item all l_item.is_argument or l_item.is_inline_separate_argument end
		do
		ensure
			no_void_item: not a_list.has_void
			valid_items: across a_list as l_item all l_item.is_argument or l_item.is_inline_separate_argument end
		end

invariant

	index_not_negative: index >= 0

end
