note

	description:

		"Eiffel parser skeletons, stop on first error"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2026, Eric Bezault and others"
	license: "MIT License"

deferred class ET_STOP_ON_FIRST_ERROR_EIFFEL_PARSER_SKELETON

inherit

	YY_PARSER_SKELETON
		rename
			make as yy_make_parser_skeleton,
			parse as yyparse,
			syntax_error as yysyntax_error
		redefine
			report_error
		end

	ET_EIFFEL_PARSER_SKELETON
		rename
			make as make_parser_skeleton
		redefine
			reset
		end

	ET_SHARED_FEATURE_NAME_TESTER
		export {NONE} all end

feature {NONE} -- Initialization

	make (a_system_processor: like system_processor)
			-- Create a new Eiffel parser.
		do
			make_stop_on_first_error_parser_skeleton
			make_parser_skeleton (a_system_processor)
			yy_make_parser_skeleton
		end

	make_stop_on_first_error_parser_skeleton
			-- Create a new stop-on-first-error parser skeleton.
		do
			create counters.make (Initial_counters_capacity)
			create last_keywords.make (Initial_last_keywords_capacity)
			create last_symbols.make (Initial_last_symbols_capacity)
		end

	reset_stop_on_first_error_parser_skeleton
			-- Reset stop-on-first-error parser skeleton.
		do
			counters.wipe_out
			last_keywords.wipe_out
			last_symbols.wipe_out
		end

feature -- Initialization

	reset
			-- Reset parser before parsing next input.
		do
			precursor
			reset_stop_on_first_error_parser_skeleton
		end

feature {NONE} -- Parsing

	parse_from_file (a_file: KI_CHARACTER_INPUT_STREAM)
			-- Parse all classes in `a_file'.
		do
			eiffel_buffer.set_file (a_file)
			yy_load_input_buffer
			yyparse
		end

	parse_from_class_text (a_class_text: STRING_8)
			-- Parse all classes in `a_class_text'.
		do
			eiffel_buffer.set_utf8_string (a_class_text)
			yy_load_input_buffer
			yyparse
		end

feature -- Error handling

	has_syntax_error: BOOLEAN
			-- Has a syntax error been found?
		do
			Result := yysyntax_error
		end

	stop_parsing
			-- Stop the parsing.
		do
			abort
		end
	
	report_error (a_message: STRING)
			-- Print error message.
		do
			report_syntax_error (current_position, Void, a_message)
		end

feature {NONE} -- Last keyword

	last_keyword: detachable ET_KEYWORD
			-- Last keyword read
		require
			last_keywords_not_empty: not last_keywords.is_empty
		do
			Result := last_keywords.item
		end

	add_keyword (a_keyword: detachable ET_KEYWORD)
			-- Add `a_keyword' to `last_keywords'.
		do
			last_keywords.force (a_keyword)
		ensure
			one_more: last_keywords.count = old last_keywords.count + 1
			keyword_added: last_keyword = a_keyword
		end

	remove_keyword
			-- Remove `last_keyword' from `last_keywords'.
		require
			last_keywords_not_empty: not last_keywords.is_empty
		do
			last_keywords.remove
		ensure
			one_less: last_keywords.count = old last_keywords.count - 1
		end

	last_keywords: DS_ARRAYED_STACK [detachable ET_KEYWORD]
			-- Last keywords read

feature {NONE} -- Last symbol

	last_symbol: detachable ET_SYMBOL
			-- Last symbol read
		require
			last_symbols_not_empty: not last_symbols.is_empty
		do
			Result := last_symbols.item
		end

	add_symbol (a_symbol: detachable ET_SYMBOL)
			-- Add `a_symbol' to `last_symbols'.
		do
			last_symbols.force (a_symbol)
		ensure
			one_more: last_symbols.count = old last_symbols.count + 1
			keyword_added: last_symbol = a_symbol
		end

	remove_symbol
			-- Remove `last_symbol' from `last_symbols'.
		require
			last_symbols_not_empty: not last_symbols.is_empty
		do
			last_symbols.remove
		ensure
			one_less: last_symbols.count = old last_symbols.count - 1
		end

	last_symbols: DS_ARRAYED_STACK [detachable ET_SYMBOL]
			-- Last symbols read

feature {NONE} -- Counters

	counter_value: INTEGER
			-- Value of the last counter registered
		require
			counters_not_empty: not counters.is_empty
		do
			Result := counters.item
		ensure
			value_positive: Result >= 0
		end

	add_counter
			-- Register a new counter.
		do
			counters.force (0)
		ensure
			one_more: counters.count = old counters.count + 1
			value_zero: counter_value = 0
		end

	remove_counter
			-- Unregister last registered counter.
		require
			counters_not_empty: not counters.is_empty
		do
			counters.remove
		ensure
			one_less: counters.count = old counters.count - 1
		end

	increment_counter
			-- Increment `counter_value'.
		require
			counters_not_empty: not counters.is_empty
		local
			a_value: INTEGER
		do
			a_value := counters.item
			counters.replace (a_value + 1)
		ensure
			same_counters_count: counters.count = old counters.count
			one_more: counter_value = old counter_value + 1
		end

	counters: DS_ARRAYED_STACK [INTEGER]
			-- Counters currently in use by the parser
			-- to build lists of AST nodes

feature {NONE} -- Constants

	Initial_counters_capacity: INTEGER = 10
			-- Initial capacity for `counters'

	Initial_last_keywords_capacity: INTEGER = 5
			-- Initial capacity for `last_keywords'

	Initial_last_symbols_capacity: INTEGER = 5
			-- Initial capacity for `last_symbols'

invariant

	counters_not_void: counters /= Void
	last_keywords_not_void: last_keywords /= Void
	last_symbols_not_void: last_symbols /= Void

end
