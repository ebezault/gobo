﻿note

	description:

		"Test XPath matches() function."

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2005-2018, Colin Adams and others"
	license: "MIT License"

class XM_XPATH_TEST_MATCHES

inherit

	TS_TEST_CASE
		redefine
			set_up
		end

	XM_XPATH_TYPE

	XM_XPATH_ERROR_TYPES

	XM_XPATH_SHARED_CONFORMANCE

	KL_IMPORTED_STRING_ROUTINES

	KL_SHARED_STANDARD_FILES

	KL_SHARED_FILE_SYSTEM
		export {NONE} all end

	UT_SHARED_FILE_URI_ROUTINES
		export {NONE} all end

	UC_UNICODE_FACTORY
		export {NONE} all end

create

	make_default

feature -- Test

	test_matches_one
			-- Test fn:matches("abracadabra", "bra") returns true.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_mixed
			an_evaluator.build_static_context (books_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("matches('abracadabra', 'bra')")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Matches", a_boolean_value.value)
			end
		end

	test_matches_two
			-- Test fn:matches("abracadabra", "^a.*a$") returns true.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_mixed
			an_evaluator.build_static_context (books_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("matches('abracadabra', '^a.*a$')")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Matches", a_boolean_value.value)
			end
		end

	test_matches_three
			-- Test fn:matches("abracadabra", "^bra") returns false.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_mixed
			an_evaluator.build_static_context (books_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("matches('abracadabra', '^bra')")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Doesnt match", not a_boolean_value.value)
			end
		end

	test_matches_four
			-- Test fn:matches(., "Kaum.*krähen") returns false when applied to poem.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_mixed
			an_evaluator.build_static_context (poem_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("matches(/*[1], 'Kaum.*krähen')")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Doesnt match", not a_boolean_value.value)
			end
		end

	test_matches_five
			-- Test fn:matches(., "Kaum.*krähen", "s") returns true when applied to poem.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_mixed
			an_evaluator.build_static_context (poem_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("matches(/*[1], 'Kaum.*krähen', 's')")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Matches", a_boolean_value.value)
			end
		end

	test_matches_four_chinese
			-- Test fn:matches returns false when applied to chinese.xml.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
			a_regular_expression: STRING
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_mixed
			an_evaluator.build_static_context (chinese_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			a_regular_expression := STRING_.concat ("matches(/*[1], '", chinese_character_one)
			a_regular_expression := STRING_.appended_string (a_regular_expression, ".*")
			a_regular_expression := STRING_.appended_string (a_regular_expression, chinese_character_two)
			a_regular_expression := STRING_.appended_string (a_regular_expression, "')")
			an_evaluator.evaluate (a_regular_expression)
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Doesnt match", not a_boolean_value.value)
			end
		end

	test_matches_five_chinese
			-- Test fn:matches returns true when applied to chinese.xml.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
			a_regular_expression: STRING
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_mixed
			an_evaluator.build_static_context (chinese_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			a_regular_expression := STRING_.concat ("matches(/*[1], '", chinese_character_one)
			a_regular_expression := STRING_.appended_string (a_regular_expression, ".*")
			a_regular_expression := STRING_.appended_string (a_regular_expression, chinese_character_two)
			a_regular_expression := STRING_.appended_string (a_regular_expression, "', 's')")
			an_evaluator.evaluate (a_regular_expression)
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Matches", a_boolean_value.value)
			end
		end

	test_matches_six
			-- Test fn:matches(., "^Kaum.*gesehen,$", "m") returns true when applied to poem.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_unicode
			an_evaluator.build_static_context (poem_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("matches(/*[1], '^Kaum.*gesehen,', 'm')")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Matches", a_boolean_value.value)
			end
		end


	test_matches_seven
			-- Test fn:matches(., "^Kaum.*gesehen,$") returns false when applied to poem.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_mixed
			an_evaluator.build_static_context (poem_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("matches(/*[1], '^Kaum.*gesehen,$')")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Doesnt match", not a_boolean_value.value)
			end
		end

	test_matches_eight
			-- Test fn:matches(., "kiki", "i") returns true when applied to poem.
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: detachable DS_LINKED_LIST [XM_XPATH_ITEM]
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_mixed
			an_evaluator.build_static_context (poem_xml_uri.full_reference, False, False, False, True)
			assert ("Build successful", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("matches(/*[1], 'kiki', 'i')")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("One evaluated item", evaluated_items /= Void and then evaluated_items.count = 1)
			check asserted_above: evaluated_items /= Void then end
			if not attached {XM_XPATH_BOOLEAN_VALUE} evaluated_items.item (1) as a_boolean_value then
				assert ("Boolean value", False)
			else
				assert ("Matches", a_boolean_value.value)
			end
		end

	set_up
		do
			conformance.set_basic_xslt_processor
		end

feature {NONE} -- Implementation

	chinese_character_one: STRING
			-- First chinese character used in regular expression
		once
			Result := new_unicode_string_filled_code (21326, 1)
		ensure
			chinese_character_one_not_void: Result /= Void
		end

	chinese_character_two: STRING
			-- Second chinese character used in regular expression
		once
			Result := new_unicode_string_filled_code (21457, 1)
		ensure
			chinese_character_two_not_void: Result /= Void
		end

	data_dirname: STRING
			-- Name of directory containing data files
		once
			Result := file_system.nested_pathname ("${GOBO}", <<"library", "xpath", "test", "unit", "data">>)
			Result := Execution_environment.interpreted_string (Result)
		ensure
			data_dirname_not_void: Result /= Void
			data_dirname_not_empty: not Result.is_empty
		end

	books_xml_uri: UT_URI
			-- URI of file 'books.xml'
		local
			a_path: STRING
		once
			a_path := file_system.pathname (data_dirname, "books.xml")
			Result := File_uri.filename_to_uri (a_path)
		ensure
			books_xml_uri_not_void: Result /= Void
		end

	poem_xml_uri: UT_URI
			-- URI of file 'poem.xml'
		local
			a_path: STRING
		once
			a_path := file_system.pathname (data_dirname, "poem.xml")
			Result := File_uri.filename_to_uri (a_path)
		ensure
			poem_xml_uri_not_void: Result /= Void
		end

	chinese_xml_uri: UT_URI
			-- URI of file 'chinese.xml'
		local
			a_path: STRING
		once
			a_path := file_system.pathname (data_dirname, "chinese.xml")
			Result := File_uri.filename_to_uri (a_path)
		ensure
			chinese_xml_uri_not_void: Result /= Void
		end

end


