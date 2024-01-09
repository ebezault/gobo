note

	description:

		"Eiffel once-procedures"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2024, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class ET_ONCE_PROCEDURE

inherit

	ET_INTERNAL_PROCEDURE
		undefine
			is_once,
			is_once_per_process,
			is_once_per_thread,
			is_once_per_object
		end

	ET_ONCE_ROUTINE

create

	make

feature -- Duplication

	new_synonym (a_name: like extended_name): like Current
			-- Synonym feature
		do
			create Result.make (a_name, arguments, implementation_class)
			Result.set_obsolete_message (obsolete_message)
			Result.set_preconditions (preconditions)
			Result.set_locals (locals)
			Result.set_compound (compound)
			Result.set_postconditions (postconditions)
			Result.set_rescue_clause (rescue_clause)
			Result.set_clients (clients)
			Result.set_is_keyword (is_keyword)
			Result.set_end_keyword (end_keyword)
			Result.set_semicolon (semicolon)
			Result.set_feature_clause (feature_clause)
			Result.set_first_indexing (first_indexing)
			Result.set_object_tests (object_tests)
			Result.set_iteration_components (iteration_components)
			Result.set_inline_separate_arguments (inline_separate_arguments)
			Result.set_synonym (Current)
		end

feature -- Conversion

	renamed_feature (a_name: like extended_name): like Current
			-- Renamed version of current feature
		do
			create Result.make (a_name, arguments, implementation_class)
			Result.set_obsolete_message (obsolete_message)
			Result.set_preconditions (preconditions)
			Result.set_locals (locals)
			Result.set_compound (compound)
			Result.set_postconditions (postconditions)
			Result.set_rescue_clause (rescue_clause)
			Result.set_clients (clients)
			Result.set_implementation_feature (implementation_feature)
			Result.set_first_precursor (first_precursor)
			Result.set_other_precursors (other_precursors)
			Result.set_is_keyword (is_keyword)
			Result.set_end_keyword (end_keyword)
			Result.set_version (version)
			Result.set_frozen_keyword (frozen_keyword)
			Result.set_semicolon (semicolon)
			Result.set_feature_clause (feature_clause)
			Result.set_first_indexing (first_indexing)
			Result.set_object_tests (object_tests)
			Result.set_iteration_components (iteration_components)
			Result.set_inline_separate_arguments (inline_separate_arguments)
			Result.set_first_seed (first_seed)
			Result.set_other_seeds (other_seeds)
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_once_procedure (Current)
		end

end
