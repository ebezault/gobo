note

	description:

		"Eiffel implementation checkers for features and invariants"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2020, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class MY_IMPLEMENTATION_CHECKER

inherit

	ET_IMPLEMENTATION_CHECKER
		redefine
			pre_action,
			post_action,
			feature_checker
		end

create

	make, make_with_feature_checker

feature {NONE} -- Processing

	pre_action
			-- <Precursor>
		do
			feature_checker.set_has_string_convert (False)
		end

	post_action
			-- <Precursor>
		local
			l_printer: MY_AST_PRINTER
			l_file: KL_TEXT_OUTPUT_FILE
		do
			if feature_checker.has_string_convert then
				if attached current_class.filename as l_filename then
					create l_file.make (l_filename)
					l_file.open_write
					create l_printer.make (l_file)
					current_class.process (l_printer)
					l_printer.set_file ({KL_SHARED_STREAMS}.null_output_stream)
					l_file.close
					error_handler.report_info_message ("Updated class " + current_class.upper_name + " in file '" + l_filename + "'")
				end
			end
		end

feature {NONE} -- Feature validity

	feature_checker: MY_FEATURE_CHECKER
			-- Feature checker

end
