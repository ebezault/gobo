﻿note

	description:

		"Test argument parsing example"

	library: "Gobo Eiffel Argument Library"
	copyright: "Copyright (c) 2006-2024, Eric Bezault and others"
	license: "MIT License"

class AP_ETEST_EXAMPLE

inherit

	EXAMPLE_TEST_CASE
		redefine
			program_dirname
		end

create

	make_default

feature -- Access

	program_name: STRING = "ap_example"
			-- Program name

	library_name: STRING = "argument"
			-- Library name of example

feature -- Test

	test_argument
			-- Test argument parsing example.
		local
			app_exe: STRING
			args: STRING
		do
			compile_program
			app_exe := program_exe
				-- Run example.
			args := "-b true -i 5"
			assert_execute_with_command_output (app_exe + " " + args + output2_log, output2_log_filename, error2_log_filename)
			assert_files_equal ("output_log1", output1_filename, output2_log_filename)
			assert_integers_equal ("no_error_log1", 0, file_system.file_count (error2_log_filename))
			args := "-a --alt-string=gobo"
			assert_execute_with_command_output (app_exe + " " + args + output3_log, output3_log_filename, error3_log_filename)
			assert_files_equal ("output_log2", output2_filename, output3_log_filename)
			assert_integers_equal ("no_error_log2", 0, file_system.file_count (error3_log_filename))
		end

feature {NONE} -- Implementation

	program_dirname: STRING
			-- Name of program source directory
		do
			Result := file_system.nested_pathname ("${GOBO}", <<"library", library_name, "example">>)
			Result := Execution_environment.interpreted_string (Result)
		end

	data_dirname: STRING
			-- Name of directory where data files are located
		once
			Result := file_system.nested_pathname ("${GOBO}", <<"library", "argument", "test", "example", "data">>)
			Result := Execution_environment.interpreted_string (Result)
		ensure
			data_dirname_not_void: Result /= Void
			data_dirname_not_empty: Result.count > 0
		end

	output1_filename: STRING
			-- Name of expected output file #1
		once
			Result := file_system.pathname (data_dirname, "output1.txt")
		ensure
			output1_filename_not_void: Result /= Void
			output1_filename_not_empty: Result.count > 0
		end

	output2_filename: STRING
			-- Name of expected output file #2
		once
			Result := file_system.pathname (data_dirname, "output2.txt")
		ensure
			output2_filename_not_void: Result /= Void
			output2_filename_not_empty: Result.count > 0
		end

end
