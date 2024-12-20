﻿note

	description:

		"Eiffel manifest arrays"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2024, Eric Bezault and others"
	license: "MIT License"

class ET_MANIFEST_ARRAY

inherit

	ET_EXPRESSION
		undefine
			is_instance_free,
			has_result,
			has_address_expression,
			has_agent,
			has_typed_object_test,
			add_old_expressions
		redefine
			reset,
			is_never_void
		end

	ET_EXPRESSION_LIST
		redefine
			make,
			make_with_capacity,
			reset,
			position,
			first_leaf
		end

create

	make, make_with_capacity

feature {NONE} -- Initialization

	make
			-- Create a new empty manifest array.
		do
			left_symbol := tokens.left_array_symbol
			right_symbol := tokens.right_array_symbol
			precursor
		end

	make_with_capacity (nb: INTEGER)
			-- Create a new empty manifest array with capacity `nb'.
		do
			left_symbol := tokens.left_array_symbol
			right_symbol := tokens.right_array_symbol
			precursor (nb)
		end

feature -- Initialization

	reset
			-- Reset manifest array as they were when they were last parsed.
		local
			l_item: ET_EXPRESSION_ITEM
			l_expression: ET_EXPRESSION
			i, nb: INTEGER
		do
			precursor {ET_EXPRESSION}
			if attached cast_type as l_cast_type then
				l_cast_type.type.reset
			end
			nb := count - 1
			from i := 0 until i > nb loop
				l_item := storage.item (i)
				l_expression := l_item.expression
				if attached {ET_CONVERT_EXPRESSION} l_expression as l_convert then
					l_expression := l_convert.expression
					if attached {ET_EXPRESSION_COMMA} l_item as l_expression_comma then
						l_expression_comma.set_expression (l_expression)
					else
						storage.put (l_expression, i)
					end
				end
				l_expression.reset
				i := i + 1
			end
		end

feature -- Status report

	is_never_void: BOOLEAN = True
			-- Can current expression never be void?

feature -- Access

	cast_type: detachable ET_TARGET_TYPE
			-- Cast type

	position: ET_POSITION
			-- Position of first character of
			-- current node in source code
		do
			if attached cast_type as l_cast_type then
				Result := l_cast_type.position
			else
				Result := precursor
			end
		end

	first_leaf: ET_AST_LEAF
			-- First leaf node in current node
		do
			if attached cast_type as l_cast_type then
				Result := l_cast_type.first_leaf
			else
				Result := precursor
			end
		end

feature -- Setting

	set_cast_type (a_type: like cast_type)
			-- Set `cast_type' to `a_type'.
		do
			cast_type := a_type
		ensure
			cast_type_set: cast_type = a_type
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_manifest_array (Current)
		end

end
