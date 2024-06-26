﻿note

	description:

		"Test 'singleton/do_nothing' example"

	library: "Gobo Eiffel Pattern Library"
	copyright: "Copyright (c) 2003-2024, Eric Bezault and others"
	license: "MIT License"

class DP_ETEST_DO_NOTHING

inherit

	EXAMPLE_TEST_CASE
		redefine
			program_dirname
		end

create

	make_default

feature -- Access

	program_name: STRING = "do_nothing"
			-- Program name

	library_name: STRING = "pattern"
			-- Library name of example

feature -- Test

	test_do_nothing
			-- Test 'singleton/do_nothing' example.
		local
			do_nothing_exe: STRING
		do
			compile_program
				-- Run example.
			do_nothing_exe := program_exe
			assert_execute_with_command_output (do_nothing_exe + output2_log, output2_log_filename, error2_log_filename)
			if file_system.same_text_files (do_nothing_log_filename, output2_log_filename) then
				assert ("output_log", True)
			else
					-- Free version of ISE Eiffel?
				file_system.delete_file (freeise_do_nothing_log_filename)
				file_system.concat_files (freeise_do_nothing_log_filename, freeise_log_filename)
				file_system.concat_files (freeise_do_nothing_log_filename, do_nothing_log_filename)
				if file_system.same_text_files (freeise_do_nothing_log_filename, output2_log_filename) then
					assert ("freeise_output_log", True)
				else
					assert_files_equal ("output_log2", do_nothing_log_filename, output2_log_filename)
				end
			end
			assert_integers_equal ("no_error_log", 0, file_system.file_count (error2_log_filename))
		end

feature {NONE} -- Implementation

	program_dirname: STRING
			-- Name of program source directory
		do
			Result := file_system.nested_pathname ("${GOBO}", <<"library", library_name, "example", "singleton", program_name>>)
			Result := Execution_environment.interpreted_string (Result)
		end

	data_dirname: STRING
			-- Name of directory where data files are located
		once
			Result := file_system.nested_pathname ("${GOBO}", <<"library", "pattern", "test", "example", "data">>)
			Result := Execution_environment.interpreted_string (Result)
		ensure
			data_dirname_not_void: Result /= Void
			data_dirname_not_empty: Result.count > 0
		end

	do_nothing_log_filename: STRING
			-- Name of file containing expected output
		once
			Result := file_system.pathname (data_dirname, "do_nothing.log")
		ensure
			do_nothing_log_filename_not_void: Result /= Void
			do_nothing_log_filename_not_empty: Result.count > 0
		end

	freeise_do_nothing_log_filename: STRING = "output2.log"
			-- Name of file containing expected output
			-- when run with the free version of ISE Eiffel
			-- under Linux/Unix

end
