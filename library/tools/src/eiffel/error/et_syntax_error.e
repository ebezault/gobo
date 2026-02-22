note

	description:

		"Eiffel syntax errors"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2026, Eric Bezault and others"
	license: "MIT License"

class ET_SYNTAX_ERROR

inherit

	ET_EIFFEL_ERROR

create

	make,
	make_error,
	make_warning

feature {NONE} -- Initialization

	make (a_filename: STRING; a_position: ET_POSITION)
			-- Create a new Eiffel syntax error at `a_position' in `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
			a_position_not_void: a_position /= Void
		local
			l_position: ET_FILE_POSITION
		do
			code := default_code
			etl_code := default_code
			default_template := default_syntax_template
			filename := a_filename
			position := a_position
			ast_node := Void
			if attached {ET_FILE_POSITION} a_position as l_file_position then
				l_position := l_file_position
			else
				create l_position.make (a_filename, a_position.line, a_position.column)
			end
			create parameters.make_filled (empty_string, 1, 1)
			parameters.put (l_position.to_text, 1)
			set_compilers (True)
		ensure
			filename_set: filename = a_filename
			position_set: position = a_position
			all_reported: all_reported
			all_fatal: all_fatal
		end

	make_error (a_filename: STRING; a_position: ET_POSITION; a_ast_node: detachable ET_AST_NODE; a_message: STRING)
			-- Create a new Eiffel syntax error at `a_position' in `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
			a_position_not_void: a_position /= Void
			a_message_not_void: a_message /= Void
		local
			l_position: ET_FILE_POSITION
		do
			code := default_code
			etl_code := default_error_code
			default_template := default_syntax_error_template
			filename := a_filename
			position := a_position
			ast_node := a_ast_node
			if attached {ET_FILE_POSITION} a_position as l_file_position then
				l_position := l_file_position
			else
				create l_position.make (a_filename, a_position.line, a_position.column)
			end
			create parameters.make_filled (empty_string, 1, 2)
			parameters.put (l_position.to_text, 1)
			parameters.put (a_message, 2)
			set_compilers (True)
		ensure
			filename_set: filename = a_filename
			position_set: position = a_position
			ast_node_set: ast_node = a_ast_node
			all_reported: all_reported
			all_fatal: all_fatal
		end

	make_warning (a_filename: STRING; a_position: ET_POSITION; a_ast_node: detachable ET_AST_NODE; a_message: STRING)
			-- Create a new Eiffel syntax warning at `a_position' in `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
			a_position_not_void: a_position /= Void
			a_message_not_void: a_message /= Void
		local
			l_position: ET_FILE_POSITION
		do
			code := default_code
			etl_code := default_warning_code
			default_template := default_syntax_warning_template
			filename := a_filename
			position := a_position
			ast_node := a_ast_node
			if attached {ET_FILE_POSITION} a_position as l_file_position then
				l_position := l_file_position
			else
				create l_position.make (a_filename, a_position.line, a_position.column)
			end
			create parameters.make_filled (empty_string, 1, 2)
			parameters.put (l_position.to_text, 1)
			parameters.put (a_message, 2)
			set_compilers (True)
		ensure
			filename_set: filename = a_filename
			position_set: position = a_position
			ast_node_set: ast_node = a_ast_node
			all_reported: all_reported
			all_fatal: all_fatal
		end

feature -- Access

	filename: STRING
			-- Name of file where current error occurred

feature -- Setting

	set_filename (a_filename: like filename)
			-- Set `filename' to `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
		do
			filename := a_filename
		ensure
			filename_set: filename = a_filename
		end

	set_current_class (a_class: like current_class)
			-- Set `current_class' to `a_class'.
		do
			current_class := a_class
		ensure
			current_class_set: current_class = a_class
		end

feature {NONE} -- Implementation

	default_syntax_template: STRING = "[SSSS] Syntax error:%N$1"
	default_syntax_error_template: STRING = "[SERR] Syntax error: $2%N$1"
	default_syntax_warning_template: STRING = "[SWRN] Syntax warning: $2%N$1"
	default_code: STRING = "ssss"
	default_error_code: STRING = "serr"
	default_warning_code: STRING = "swrn"
			-- Default values

end
