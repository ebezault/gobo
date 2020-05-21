note

	description:

	"[
		Eiffel AST printers.
		Use UTF-8 encoding. Note that the byte order mark (BOM) for UTF-8 is not
		printed unless it was found in the class file when parsing the class text
		and `bom_enabled' is True, or it is explicitly printed by calling `print_bom'.
	]"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2020, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class MY_AST_PRINTER

inherit

	ET_AST_PRINTER
		redefine
			make,
			process_convert_to_expression
		end

	ET_SHARED_TOKEN_CONSTANTS
		export {NONE} all end

create

	make, make_null

feature {NONE} -- Initialization

	make (a_file: like file)
			-- <Precursor>
		do
			create convert_buffer.make_empty
			precursor (a_file)
		end

feature {ET_AST_NODE} -- Processing

	process_convert_to_expression (a_convert_expression: ET_CONVERT_TO_EXPRESSION)
			-- <Precursor>
		local
			l_need_parentheses: BOOLEAN
			l_expression: ET_EXPRESSION
			l_old_file: like file
			l_break: detachable ET_BREAK
		do
			if attached {MY_CONVERT_TO_EXPRESSION} a_convert_expression then
				l_expression := a_convert_expression.expression
				if
					not attached {ET_PARENTHESIZED_EXPRESSION} l_expression and
					not attached {ET_IDENTIFIER} l_expression and
					not attached {ET_UNQUALIFIED_CALL_EXPRESSION} l_expression and
					not attached {ET_QUALIFIED_CALL_EXPRESSION} l_expression and
					not attached {ET_BRACKET_EXPRESSION} l_expression
				then
					l_need_parentheses := True
				end
				if l_need_parentheses then
					tokens.left_parenthesis_symbol.process (Current)
				end
				l_old_file := file
				convert_buffer.string.wipe_out
				file := convert_buffer
				l_expression.process (Current)
				l_break := l_expression.last_leaf.break
				if l_break /= Void then
					convert_buffer.string.remove_tail (l_break.text.count)
				end
				file := l_old_file
				file.put_string (convert_buffer.string)
				if l_need_parentheses then
					tokens.right_parenthesis_symbol.process (Current)
				end
				tokens.dot_symbol.process (Current)
				a_convert_expression.name.process (Current)
				process_break (l_break)
			else
				precursor (a_convert_expression)
			end
		end

feature {NONE} -- Implementation

	convert_buffer: KL_STRING_OUTPUT_STREAM
			-- Buffer to print converted expressions

invariant

	convert_buffer_not_void: convert_buffer /= Void

end
