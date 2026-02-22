note

	description:

		"Dual Eiffel parsers, using two parsing strategies"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class ET_DUAL_EIFFEL_PARSER

inherit

	ET_STOP_ON_FIRST_ERROR_EIFFEL_PARSER
		rename
			read_token as yy_read_token
		undefine
			set_syntax_error,
			report_syntax_error
		redefine
			make,
			reset,
			system_processor,
			parse_from_file,
			parse_from_class_text,
			has_syntax_error,
			stop_parsing
		end

	ET_FAULT_TOLERANT_EIFFEL_PARSER
		redefine
			make,
			reset,
			system_processor,
			parse_from_file,
			parse_from_class_text,
			has_syntax_error,
			stop_parsing
		end

create

	make

feature {NONE} -- Initialization

	make (a_system_processor: like system_processor)
			-- Create a new Eiffel parser.
		do
			make_fault_tolerant_parser_skeleton
			precursor {ET_STOP_ON_FIRST_ERROR_EIFFEL_PARSER} (a_system_processor)
		end
		
feature -- Initialization

	reset
			-- Reset parser before parsing next input.
		do
			precursor {ET_STOP_ON_FIRST_ERROR_EIFFEL_PARSER}
			reset_fault_tolerant_parser_skeleton
		end

feature -- Access

	system_processor: ET_SYSTEM_PROCESSOR
			-- System processor currently used
feature {NONE} -- Parsing

	parse_from_file (a_file: KI_CHARACTER_INPUT_STREAM)
			-- Parse all classes in `a_file'.
			-- Fast stop-on-first-error parsing first,
			-- reparse with slower fault-tolerant parser
			-- when a syntax error was found.
		local
			l_old_ast_factory: ET_AST_FACTORY
			l_old_error_handler: detachable ET_ERROR_HANDLER
			l_text_file: detachable KL_TEXT_INPUT_FILE
			l_cluster: detachable ET_CLUSTER
		do
			if not attached {ET_DECORATED_AST_FACTORY} ast_factory and attached {KL_TEXT_INPUT_FILE} a_file as l_file and attached {ET_CLUSTER} group as l_group_cluster then
				l_text_file := l_file
				l_cluster := l_group_cluster
				l_old_error_handler := error_handler
				system_processor.set_error_handler_only (tokens.null_error_handler)
			end
			precursor {ET_STOP_ON_FIRST_ERROR_EIFFEL_PARSER} (a_file)
			if l_old_error_handler /= Void then
				system_processor.set_error_handler_only (l_old_error_handler)
			end
			if has_syntax_error and l_text_file /= Void and l_cluster /= Void then
				reset
				l_old_ast_factory := ast_factory
				system_processor.set_ast_factory_only (tokens.decorated_ast_factory)
				l_text_file.close
				l_text_file.open_read
				if l_text_file.is_open_read then
					precursor {ET_FAULT_TOLERANT_EIFFEL_PARSER} (l_text_file)
				else
					error_handler.report_gcaab_error (l_cluster, filename)
				end
				system_processor.set_ast_factory_only (l_old_ast_factory)
				if not has_syntax_error and attached last_syntax_error_position as l_position then
					report_syntax_error (l_position, Void, "")
				end
				accept
			end
		end

	parse_from_class_text (a_class_text: STRING_8)
			-- Parse all classes in `a_class_text'.
			-- Fast stop-on-first-error parsing first,
			-- reparse with slower fault-tolerant parser
			-- when a syntax error was found.
		local
			l_old_ast_factory: ET_AST_FACTORY
			l_old_error_handler: detachable ET_ERROR_HANDLER
			l_fault_tolerant: BOOLEAN
		do
			if not attached {ET_DECORATED_AST_FACTORY} ast_factory then
				l_fault_tolerant := True
				l_old_error_handler := error_handler
				system_processor.set_error_handler_only (tokens.null_error_handler)
			end
			precursor {ET_STOP_ON_FIRST_ERROR_EIFFEL_PARSER} (a_class_text)
			if l_old_error_handler /= Void then
				system_processor.set_error_handler_only (l_old_error_handler)
			end
			if has_syntax_error and l_fault_tolerant then
				reset
				l_old_ast_factory := ast_factory
				system_processor.set_ast_factory_only (tokens.decorated_ast_factory)
				precursor {ET_FAULT_TOLERANT_EIFFEL_PARSER} (a_class_text)
				system_processor.set_ast_factory_only (l_old_ast_factory)
				if not has_syntax_error and attached last_syntax_error_position as l_position then
					report_syntax_error (l_position, Void, "")
				end
				accept
			end
		end

feature -- Error handling

	has_syntax_error: BOOLEAN
			-- Has a syntax error been found?
		do
			Result := internal_has_syntax_error or yysyntax_error
		end

	stop_parsing
			-- Stop the parsing.
		do
			is_parsing_stopped := True
			accept
		end

end
