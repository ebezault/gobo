indexing

	description:

		"Gobo Eiffel Ant: build tool for Eiffel, based on the concepts of Jakarta Ant"

	library: "Gobo Eiffel Ant"
	copyright: "Copyright (c) 2001, Sven Ehrke and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"


class GEANT

inherit

	GEANT_VERSION

	GEANT_SHARED_PROPERTIES
		export
			{NONE} all
		end

	KL_SHARED_ARGUMENTS
		export
			{NONE} all
		end

	KL_SHARED_EXCEPTIONS
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make is
			-- Execute 'geant'.
		local
			a_project: GEANT_PROJECT
			ucs: UC_STRING
		do
			Arguments.set_program_name ("geant")
			!! error_handler.make_standard
			read_command_line

			if build_filename /= void and then build_filename.count > 0 then
				ucs := new_unicode_string (build_filename)
				!! a_project.make_with_filename(ucs, Void, Void)
			else
				!! a_project.make (Void)
			end

			a_project.set_verbose (verbose)
			a_project.set_debug_mode (debug_mode)
			a_project.set_no_exec (no_exec)
			a_project.load (start_target_name)
			if a_project.targets /= Void then
				a_project.build
				if not a_project.build_successful then
					exit_application (1, Void)
				end
			end
		end


feature -- Access

	error_handler: UT_ERROR_HANDLER
			-- Error handler

	build_filename: STRING
			-- Build filename for geant.

	start_target_name: STRING
			-- Name of the target the build process starts with

	verbose: BOOLEAN
			-- Print additional information during build process?

	debug_mode: BOOLEAN
		-- Print additional, internal information during build process?

	no_exec: BOOLEAN
			-- Do not execute commands (only show what they would do)?

	read_command_line is
			-- Read command line arguments.
		local
			i, nb: INTEGER
			p: INTEGER
			arg: STRING
			a_variable_name: STRING
			a_variable_value: STRING
		do
			nb := Arguments.argument_count
			from i := 1 until i > nb loop
				arg := Arguments.argument (i)
				if arg.is_equal ("--version") then
					report_version_number
				elseif arg.is_equal ("--verbose") or arg.is_equal ("-v") then
					set_verbose (true)
				elseif arg.is_equal ("--noexec") or arg.is_equal ("-n") then
					set_no_exec (true)
				elseif arg.is_equal ("--debug") or arg.is_equal ("-d") then
					set_debug_mode (true)
				elseif arg.is_equal ("--help") or arg.is_equal ("-h") or arg.is_equal ("-?") then
					report_usage_message
				elseif arg.is_equal ("-b") then
					i := i + 1
					if i > nb then
						report_usage_error
					else
						build_filename := Arguments.argument (i)
					end
				elseif arg.count > 16 and then arg.substring (1, 16).is_equal ("--buildfilename=") then
					build_filename := arg.substring (16, arg.count)
				elseif arg.count > 1 and then arg.item (1) = '-' and then arg.item (2) = 'D' then
					p := arg.index_of('=', 1)
					if p > 3 and p < arg.count then
							-- define commandline variable with value:
						a_variable_name := clone (arg.substring (3, p - 1))
						a_variable_value := clone (arg.substring (p + 1, arg.count))
						Commandline_variables.force (a_variable_value, a_variable_name)
					elseif arg.count > 2 and then p = 0 then
							-- define commandline variable:
						a_variable_name := clone (arg.substring (3, arg.count))
						Commandline_variables.force ("True", a_variable_name)
					end
				elseif i = nb then
					start_target_name := arg
				else
					report_usage_error
				end
				i := i + 1
			end
		end

feature -- Setting

	set_verbose (a_verbose: BOOLEAN) is
			-- Set `verbose' to `a_verbose'
		do
			verbose := a_verbose
		ensure
			verbose_set: verbose = a_verbose
		end

	set_debug_mode (a_debug_mode: BOOLEAN) is
			-- Set `debug_mode' to `a_debug_mode'
		do
			debug_mode := a_debug_mode
		ensure
			debug_mode_set: debug_mode = a_debug_mode
		end

	set_no_exec (a_no_exec: BOOLEAN) is
			-- Set `no_exec' to `a_no_exec'
		do
			no_exec := a_no_exec
		ensure
			no_exec_set: no_exec = a_no_exec
		end

feature {NONE} -- Error handling

	report_usage_error is
			-- Report usage error and then terminate
			-- with exit status 1.
		do
			error_handler.report_error (Usage_message)
			exit_application (1, Void)
		end

	report_usage_message is
			-- Report usage message and exit.
		do
			error_handler.report_message (Usage_message)
			exit_application (0, Void)
		end

	report_version_number is
			-- Report version number and exit.
		local
			a_message: UT_VERSION_NUMBER
		do
			!! a_message.make (Version_number)
			error_handler.report_message (a_message)
			exit_application (0, Void)
		end

	Usage_message: UT_USAGE_MESSAGE is
			-- Geant usage message
		local
			s: STRING
		once
			s := clone ("[-options] [target]")
			s.append_string ("%N")
			s.append_string ("where options include:%N")
			s.append_string ("  --version : Show version%N")
			s.append_string ("  -v --verbose : Turn on verbose output%N")
			s.append_string ("  -b --buildfilename <buildfilename> : Specify buildfile (default: 'build.eant'%N")
			s.append_string ("  -n --noexec : Do not execute tasks, just show what they would do%N")
			s.append_string ("  -D<variable> : Define variable named 'variable' with value 'True'%N")
			s.append_string ("  -D<variable>=<value> : Define variable named 'variable' with value 'value'%N")
			s.append_string ("  -d --debug : Show internal messages%N")
			s.append_string ("  -? -h help : Print this help message%N")

			!! Result.make (s)
		ensure
			usage_message_not_void: Result /= Void
		end

end
