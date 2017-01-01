note

	description:

		"Test for validity rule VTCT"

	copyright: "Copyright (c) 2016, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class TEST_VTCT_TEST5

inherit

	GELINT_TEST_CASE

create

	make_default

feature -- Test

	test_validity
			-- Test for validity rule VTCT.
		do
			compile_and_test ("test5")
		end

feature {NONE} -- Implementation

	rule_dirname: STRING
			-- Name of the directory containing the tests of the rule being tested
		do
			Result := file_system.nested_pathname ("${GOBO}", <<"test", "gelint", "validity", "vtct">>)
			Result := Execution_environment.interpreted_string (Result)
		end

	testdir: STRING
			-- Name of temporary directory where to run the test
		do
			Result := "Ttest5"
		end

end
