note

	description:

		"[
			Gobo Eiffel Conveet.
			Make explicit the implicit conversions from [READABLE_]STRING_32 to [READABLE_]STRING_8.
		]"

	copyright: "Copyright (c) 2020, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class GECONVERT

inherit

	KL_SHARED_EXCEPTIONS
	KL_SHARED_ARGUMENTS

	UT_SHARED_ISE_VERSIONS
		export {NONE} all end

	ET_SHARED_ISE_VARIABLES
		export {NONE} all end

create

	execute

feature -- Execution

	execute
			-- Start 'geconvert' execution.
		local
			l_filename: STRING
			l_file: KL_TEXT_INPUT_FILE
		do
			Arguments.set_program_name ("geconvert")
				-- For compatibility with ISE's tools, define the environment
				-- variable "$ISE_LIBRARY" to $ISE_EIFFEL" if not set yet.
			ise_variables.set_ise_library_variable
			create error_handler.make_standard
			parse_arguments
			l_filename := ecf_filename
			create l_file.make (l_filename)
			l_file.open_read
			if l_file.is_open_read then
				last_system := Void
				parse_ecf_file (l_file)
				l_file.close
				if attached last_system as l_last_system then
					process_system (l_last_system)
					if error_handler.has_eiffel_error then
						Exceptions.die (2)
					elseif error_handler.has_internal_error then
						Exceptions.die (5)
					end
				else
					Exceptions.die (3)
				end
			else
				report_cannot_read_error (l_filename)
				Exceptions.die (1)
			end
		rescue
			Exceptions.die (4)
		end

feature -- Access

	last_system: detachable ET_SYSTEM
			-- Last system parsed, if any

feature {NONE} -- Eiffel config file parsing

	parse_ecf_file (a_file: KI_CHARACTER_INPUT_STREAM)
			-- Read ECF file `a_file'.
			-- Put result in `last_system' if no error occurred.
		require
			a_file_not_void: a_file /= Void
			a_file_open_read: a_file.is_open_read
		local
			l_ecf_parser: ET_ECF_SYSTEM_PARSER
			l_ecf_error_handler: ET_ECF_ERROR_HANDLER
		do
			last_system := Void
			create l_ecf_error_handler.make_standard
			create l_ecf_parser.make (l_ecf_error_handler)
			l_ecf_parser.parse_file (a_file, target_name)
			if not l_ecf_error_handler.has_error then
				last_system := l_ecf_parser.last_system
			end
		end

feature {NONE} -- Processing

	process_system (a_system: ET_SYSTEM)
			-- Process `a_system'.
		require
			a_system_not_void: a_system /= Void
		local
			l_system_processor: ET_SYSTEM_PROCESSOR
			dt1: detachable DT_DATE_TIME
			l_implementation_checker: MY_IMPLEMENTATION_CHECKER
			l_ast_factory: ET_DECORATED_AST_FACTORY
		do
			error_handler.set_ise
			l_system_processor := {ET_SYSTEM_PROCESSOR_FACTORY}.new_system_processor (thread_count)
			create l_implementation_checker.make (l_system_processor)
			l_system_processor.set_implementation_checker (l_implementation_checker)
			if attached {ET_SYSTEM_MULTIPROCESSOR} l_system_processor as l_system_multiprocessor then
				across l_system_multiprocessor.other_processors is l_other_processor loop
					create l_implementation_checker.make (l_other_processor)
					l_other_processor.set_implementation_checker (l_implementation_checker)
				end
			end
			create l_ast_factory.make
			l_ast_factory.set_keep_all_breaks (True)
			l_system_processor.set_ast_factory (l_ast_factory)
			l_system_processor.set_benchmark_shown (True)
			l_system_processor.set_error_handler (error_handler)
			l_system_processor.set_ise_version (ise_latest)
			l_system_processor.set_flat_mode (False)
			l_system_processor.set_flat_dbc_mode (False)
			l_system_processor.set_unknown_builtin_reported (False)
			dt1 := l_system_processor.benchmark_start_time
			l_system_processor.set_providers_enabled (True)
			l_system_processor.set_cluster_dependence_enabled (False)
			l_system_processor.compile_all (a_system)
			l_system_processor.record_end_time (dt1, "Total Time")
		end

feature -- Arguments

	ecf_filename: STRING
			-- Name of the ECF file

	target_name: detachable STRING
			-- Name of target to be used in ECF file.
			-- Use last target in ECF file if not specified.
		do
			if target_option.was_found then
				Result := target_option.parameter
			end
		end

	thread_count: INTEGER
			-- Number of threads to be used
		do
			Result := {EXECUTION_ENVIRONMENT}.available_cpu_count.as_integer_32
			if thread_option.was_found then
				Result := thread_option.parameter
				if Result <= 0 then
					Result := {EXECUTION_ENVIRONMENT}.available_cpu_count.as_integer_32 + Result
				end
			end
			if Result < 1 or not {PLATFORM}.is_thread_capable then
				Result := 1
			end
		ensure
			thread_count_not_negative: Result >= 1
		end

feature -- Argument parsing

	target_option: AP_STRING_OPTION
			-- Option for '--target=<target_name>'

	thread_option: AP_INTEGER_OPTION
			-- Option for '--thread=<thread_count>'

	parse_arguments
			-- Initialize options and parse the command line.
		local
			l_parser: AP_PARSER
		do
			create l_parser.make
			l_parser.set_application_description ("Gobo Eiffel Convert.")
			l_parser.set_parameters_description ("ecf_filename")
				-- target.
			create target_option.make_with_long_form ("target")
			target_option.set_description ("Name of target to be used in ECF file. (default: last target in ECF file)")
			target_option.set_parameter_description ("target_name")
			l_parser.options.force_last (target_option)
				-- thread.
			create thread_option.make_with_long_form ("thread")
			thread_option.set_description ("Number of threads to be used. Negative numbers -N mean %"number of CPUs - N%". (default: number of CPUs)")
			thread_option.set_parameter_description ("thread_count")
			if {PLATFORM}.is_thread_capable then
				l_parser.options.force_last (thread_option)
			end
				-- Parsing.
			l_parser.parse_arguments
			if l_parser.parameters.count /= 1 then
				report_usage_message (l_parser)
				ecf_filename := ""
				Exceptions.die (1)
			else
				ecf_filename := l_parser.parameters.first
			end
		ensure
			target_option_not_void: target_option /= Void
			thread_option_not_void: thread_option /= Void
		end

feature -- Error handling

	error_handler: ET_ERROR_HANDLER
			-- Error handler

	report_cannot_read_error (a_filename: STRING)
			-- Report that `a_filename' cannot be
			-- opened in read mode.
		require
			a_filename_not_void: a_filename /= Void
		local
			an_error: UT_CANNOT_READ_FILE_ERROR
		do
			create an_error.make (a_filename)
			error_handler.report_error (an_error)
		end

	report_usage_message (a_parser: AP_PARSER)
			-- Report usage message.
		require
			a_parser_not_void: a_parser /= Void
		local
			l_error: UT_MESSAGE
		do
			create l_error.make (a_parser.full_usage_instruction)
			error_handler.report_error (l_error)
		end

invariant

	error_handler_not_void: error_handler /= Void
	ecf_filename_not_void: ecf_filename /= Void
	target_option_not_void: target_option /= Void
	thread_option_not_void: thread_option /= Void

end
