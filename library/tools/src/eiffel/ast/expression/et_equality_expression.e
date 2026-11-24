note

	description:

		"Eiffel equality expressions (i.e. '=' and '/=')"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2026, Eric Bezault and others"
	license: "MIT License"

class ET_EQUALITY_EXPRESSION

inherit

	ET_BINARY_EXPRESSION
		redefine
			reset,
			add_formal_arguments
		end

create

	make

feature {NONE} -- Initialization

	make (a_left: like left; an_operator: like operator; a_right: like right)
			-- Create a new equality expression.
		require
			a_left_not_void: a_left /= Void
			an_operator_not_void: an_operator /= Void
			a_right_not_void: a_right /= Void
		do
			left := a_left
			operator := an_operator
			right := a_right
		ensure
			left_set: left = a_left
			operator_set: operator = an_operator
			right_set: right = a_right
		end

feature -- Initialization

	reset
			-- Reset expression as it was just after it was last parsed.
		do
			precursor
			if attached {ET_CONVERT_EXPRESSION} left as l_convert then
				left := l_convert.expression
			end
			left.reset
			if attached {ET_CONVERT_EXPRESSION} right as l_convert then
				right := l_convert.expression
			end
			right.reset
		end

feature -- Access

	operator: ET_SYMBOL
			-- Operator symbol ('=' or '/=')

feature -- Setting

	set_operator (a_operator: like operator)
			-- Set `operator' to `a_operator'.
		require
			a_operator_not_void: a_operator /= Void
		do
			operator := a_operator
		ensure
			operator_set: operator = a_operator
		end

feature -- Formal arguments

	add_formal_arguments (a_list: DS_ARRAYED_LIST_2 [detachable ET_IDENTIFIER, BOOLEAN])
			-- Add to `a_list' all formal arguments appearing in current expression
			-- and (recursively) in its subexpressions: set the boolean to true
			-- if the formal argument name at the index corresponding to its seed
			-- is not Void.
			-- Note: do not take into account attachment tests for formal arguments
			-- (e.g. 'a /= Void' or 'attached a').
		do
			if attached {ET_VOID} right and then attached {ET_IDENTIFIER} left as l_left and then l_left.is_argument then
				-- Attachment test.
			elseif attached {ET_VOID} left and then attached {ET_IDENTIFIER} right as l_right and then l_right.is_argument then
				-- Attachment test.
			else
				precursor (a_list)
			end
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_equality_expression (Current)
		end

invariant

	operator_not_void: operator /= Void

end
