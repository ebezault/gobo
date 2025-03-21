﻿note

	description:

		"Eiffel loop invariants"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004-2024, Eric Bezault and others"
	license: "MIT License"

class ET_LOOP_INVARIANTS

inherit

	ET_ASSERTIONS
		redefine
			make, make_with_capacity
		end

create

	make, make_with_capacity

feature {NONE} -- Initialization

	make
			-- Create a new invariant clause.
		do
			invariant_keyword := tokens.invariant_keyword
			precursor
		end

	make_with_capacity (nb: INTEGER)
			-- Create a new invariant clause with capacity `nb'.
		do
			invariant_keyword := tokens.invariant_keyword
			precursor (nb)
		end

feature -- Access

	invariant_keyword: ET_INVARIANT_KEYWORD
			-- 'invariant' keyword

	position: ET_POSITION
			-- Position of first character of
			-- current node in source code
		do
			Result := invariant_keyword.position
			if Result.is_null then
				if not is_empty then
					Result := item (1).position
				elseif attached first_semicolon as l_first_semicolon then
					Result := l_first_semicolon.last_leaf
				end
			end
		end

	first_leaf: ET_AST_LEAF
			-- First leaf node in current node
		do
			Result := invariant_keyword
		end

	last_leaf: ET_AST_LEAF
			-- Last leaf node in current node
		do
			if not is_empty then
				Result := last.last_leaf
			elseif attached first_semicolon as l_first_semicolon then
				Result := l_first_semicolon.last_leaf
			else
				Result := invariant_keyword
			end
		end

feature -- Setting

	set_invariant_keyword (an_invariant: like invariant_keyword)
			-- Set `invariant_keyword' to `an_invariant'.
		require
			an_invariant_not_void: an_invariant /= Void
		do
			invariant_keyword := an_invariant
		ensure
			invariant_keyword_not_void: invariant_keyword = an_invariant
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_loop_invariants (Current)
		end

invariant

	invariant_keyword_not_void: invariant_keyword /= Void

end
