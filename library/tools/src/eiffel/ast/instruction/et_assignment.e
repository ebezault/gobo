﻿note

	description:

		"Eiffel assignment instructions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2024, Eric Bezault and others"
	license: "MIT License"

class ET_ASSIGNMENT

inherit

	ET_INSTRUCTION
		redefine
			reset,
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test
		end

create

	make

feature {NONE} -- Initialization

	make (a_target: like target; a_source: like source)
			-- Create a new assignment instruction.
		require
			a_target_not_void: a_target /= Void
			a_source_not_void: a_source /= Void
		do
			target := a_target
			source := a_source
			assign_symbol := tokens.assign_symbol
		ensure
			target_set: target = a_target
			source_set: source = a_source
		end

feature -- Initialization

	reset
			-- Reset instruction as it was just after it was last parsed.
		do
			target.reset
			if attached {ET_CONVERT_EXPRESSION} source as l_convert then
				source := l_convert.expression
			end
			source.reset
		end

feature -- Access

	target: ET_WRITABLE
			-- Target of assignment

	source: ET_EXPRESSION
			-- Source of assignment

	assign_symbol: ET_SYMBOL
			-- ':=' symbol

	position: ET_POSITION
			-- Position of first character of
			-- current node in source code
		do
			Result := target.position
		end

	first_leaf: ET_AST_LEAF
			-- First leaf node in current node
		do
			Result := target.first_leaf
		end

	last_leaf: ET_AST_LEAF
			-- Last leaf node in current node
		do
			Result := source.last_leaf
		end

feature -- Status report

	no_source_twin: BOOLEAN
			-- Should the source object not be cloned even when needed
			-- (e.g. when its type is expanded)?

	has_result: BOOLEAN
			-- Does the entity 'Result' appear in current instruction or
			-- (recursively) in one of its subinstructions or subexpressions?
		do
			Result := target.has_result or source.has_result
		end

	has_address_expression: BOOLEAN
			-- Does an address expression appear in current instruction or
			-- (recursively) in one of its subinstructions or subexpressions?
		do
			Result := target.has_address_expression or source.has_address_expression
		end

	has_agent: BOOLEAN
			-- Does an agent appear in current instruction or
			-- (recursively) in one of its subinstructions or subexpressions?
		do
			Result := target.has_agent or source.has_agent
		end

	has_typed_object_test: BOOLEAN
			-- Does a typed object-test appear in current instruction or
			-- (recursively) in one of its subinstructions or subexpressions?
		do
			Result := target.has_typed_object_test or source.has_typed_object_test
		end

feature -- Status setting

	set_no_source_twin (b: BOOLEAN)
			-- Set `no_source_twin' to `b'.
		do
			no_source_twin := b
		ensure
			no_source_twin_set: no_source_twin = b
		end

feature -- Setting

	set_source (a_source: like source)
			-- Set `source' to `a_source'.
		require
			a_source_not_void: a_source /= Void
		do
			source := a_source
		ensure
			source_set: source = a_source
		end

	set_assign_symbol (an_assign: like assign_symbol)
			-- Set `assign_symbol' to `an_assign'.
		require
			an_assign_not_void: an_assign /= Void
		do
			assign_symbol := an_assign
		ensure
			assign_symbol_set: assign_symbol = an_assign
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_assignment (Current)
		end

invariant

	target_not_void: target /= Void
	source_not_void: source /= Void
	assign_symbol_not_void: assign_symbol /= Void

end
