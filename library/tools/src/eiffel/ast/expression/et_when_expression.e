﻿note

	description:

		"Eiffel 'when' parts in inspect expressions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2020-2024, Eric Bezault and others"
	license: "MIT License"

class ET_WHEN_EXPRESSION

inherit

	ET_AST_NODE

create

	make

feature {NONE} -- Initialization

	make (a_choices: like choices; a_then_expression: like then_expression)
			-- Create a new when part.
		require
			a_choices_not_void: a_choices /= Void
			a_then_expression_not_void: a_then_expression /= Void
		do
			choices := a_choices
			then_keyword := tokens.then_keyword
			then_expression := a_then_expression
		ensure
			choices_set: choices = a_choices
			then_expression_set: then_expression = a_then_expression
		end

feature -- Initialization

	reset
			-- Reset when part as it was when it was last parsed.
		do
			choices.reset
			then_expression.reset
		end

feature -- Access

	choices: ET_CHOICE_LIST
			-- Choices

	then_keyword: ET_KEYWORD
			-- Then keyword

	then_expression: ET_EXPRESSION
			-- Then expression

	position: ET_POSITION
			-- Position of first character of
			-- current node in source code
		do
			Result := choices.position
		end

	first_leaf: ET_AST_LEAF
			-- First leaf node in current node
		do
			Result := choices.first_leaf
		end

	last_leaf: ET_AST_LEAF
			-- Last leaf node in current node
		do
			Result := then_expression.last_leaf
		end

feature -- Status report

	is_instance_free: BOOLEAN
			-- Does current 'when' part not depend on 'Current' or its attributes?
			-- Note that we do not consider unqualified calls and Precursors as
			-- instance-free because it's not always possible syntactically
			-- to determine whether the feature being called is a class feature
			-- or not.
		do
			Result := then_expression.is_instance_free
		end

	has_result: BOOLEAN
			-- Does the entity 'Result' appear in current when part
			-- or (recursively) in one of its subexpressions?
		do
			Result := then_expression.has_result
		end

	has_address_expression: BOOLEAN
			-- Does an address expression appear in current when part
			-- or (recursively) in one of its subexpressions?
		do
			Result := then_expression.has_address_expression
		end

	has_agent: BOOLEAN
			-- Does an agent appear in current when part
			-- or (recursively) in one of its subexpressions?
		do
			Result := then_expression.has_agent
		end

	has_typed_object_test: BOOLEAN
			-- Does a typed object-test appear in current when part
			-- or (recursively) in one of its subexpressions?
		do
			Result := then_expression.has_typed_object_test
		end

feature -- Setting

	set_then_keyword (a_then: like then_keyword)
			-- Set `then_keyword' to `a_then'.
		do
			then_keyword := a_then
		ensure
			then_keyword_set: then_keyword = a_then
		end

feature -- Assertions

	add_old_expressions (a_list: DS_ARRAYED_LIST [ET_OLD_EXPRESSION])
			-- Add to `a_list' all old expressions appearing in current when part
			-- and (recursively) in its subexpressions.
		require
			a_list_not_void: a_list /= Void
			no_void_item: not a_list.has_void
		do
			then_expression.add_old_expressions (a_list)
		ensure
			no_void_item: not a_list.has_void
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_when_expression (Current)
		end

invariant

	choices_not_void: choices /= Void
	then_keyword_not_void: then_keyword /= Void
	then_expression_not_void: then_expression /= Void

end
