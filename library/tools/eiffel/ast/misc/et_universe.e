indexing

	description:

		"Eiffel class universes"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_UNIVERSE

inherit

	KL_IMPORTED_STRING_ROUTINES
	KL_SHARED_STANDARD_FILES
	ET_SHARED_CLASS_NAME_TESTER
	ET_SHARED_TOKEN_CONSTANTS

creation

	make, make_standard, make_with_factory

feature {NONE} -- Initialization

	make_standard is
			-- Create a new class universe.
			-- Error messages will be sent to standard files.
		local
			a_handler: ET_ERROR_HANDLER
		do
			create a_handler.make_standard
			make (Void, a_handler)
		end

	make (a_clusters: like clusters; an_error_handler: like error_handler) is
			-- Create a new class universe.
		require
			an_error_handler_not_void: an_error_handler /= Void
		local
			a_factory: ET_AST_FACTORY
		do
			create a_factory.make
			make_with_factory (a_clusters, a_factory, an_error_handler)
		ensure
			clusters_set: clusters = a_clusters
			error_handler_set: error_handler = an_error_handler
		end

	make_with_factory (a_clusters: like clusters; a_factory: like ast_factory;
		an_error_handler: like error_handler) is
			-- Create a new class universe.
		require
			an_error_handler_not_void: an_error_handler /= Void
			a_factory_not_void: a_factory /= Void
		do
			clusters := a_clusters
			create classes.make_map (3000)
			classes.set_key_equality_tester (class_name_tester)
			error_handler := an_error_handler
			ast_factory := a_factory
			set_use_assign_keyword (True)
			set_use_attribute_keyword (True)
			set_use_convert_keyword (True)
			set_use_create_keyword (True)
			set_use_recast_keyword (True)
			set_use_reference_keyword (True)
			set_use_void_keyword (True)
			make_basic_classes
			create cluster_processor.make (Current)
			create null_processor.make (Current)
			ancestor_builder := null_processor
			feature_flattener := null_processor
			qualified_signature_resolver := null_processor
			interface_checker := null_processor
			implementation_checker := null_processor
		ensure
			clusters_set: clusters = a_clusters
			ast_factory_set: ast_factory = a_factory
			error_handler_set: error_handler = an_error_handler
		end

	make_basic_classes is
			-- Create basic classes.
		local
			a_parameters: ET_ACTUAL_PARAMETER_LIST
		do
				-- Basic classes.
			any_class := eiffel_class (tokens.any_class_name)
			any_class.set_in_system (True)
			general_class := eiffel_class (tokens.general_class_name)
			none_class := eiffel_class (tokens.none_class_name)
			none_class.set_in_system (True)
			tuple_class := eiffel_class (tokens.tuple_class_name)
			tuple_class.set_in_system (True)
			bit_class := eiffel_class (tokens.bit_class_name)
			bit_class.set_in_system (True)
			string_class := eiffel_class (tokens.string_class_name)
			string_class.set_in_system (True)
			array_class := eiffel_class (tokens.array_class_name)
			array_class.set_in_system (True)
			boolean_class := eiffel_class (tokens.boolean_class_name)
			boolean_class.set_in_system (True)
			character_class := eiffel_class (tokens.character_class_name)
			character_class.set_in_system (True)
			wide_character_class := eiffel_class (tokens.wide_character_class_name)
			wide_character_class.set_in_system (True)
			integer_class := eiffel_class (tokens.integer_class_name)
			integer_class.set_in_system (True)
			integer_8_class := eiffel_class (tokens.integer_8_class_name)
			integer_8_class.set_in_system (True)
			integer_16_class := eiffel_class (tokens.integer_16_class_name)
			integer_16_class.set_in_system (True)
			integer_64_class := eiffel_class (tokens.integer_64_class_name)
			integer_64_class.set_in_system (True)
			real_class := eiffel_class (tokens.real_class_name)
			real_class.set_in_system (True)
			double_class := eiffel_class (tokens.double_class_name)
			double_class.set_in_system (True)
			pointer_class := eiffel_class (tokens.pointer_class_name)
			pointer_class.set_in_system (True)
			typed_pointer_class := eiffel_class (tokens.typed_pointer_class_name)
			typed_pointer_class.set_in_system (True)
			procedure_class := eiffel_class (tokens.procedure_class_name)
			procedure_class.set_in_system (True)
			predicate_class := eiffel_class (tokens.predicate_class_name)
			predicate_class.set_in_system (True)
			function_class := eiffel_class (tokens.function_class_name)
			function_class.set_in_system (True)
				-- Unknown class.
			create unknown_class.make_unknown (tokens.unknown_class_name)
				-- Type "ANY".
			create any_type.make (Void, any_class.name, any_class)
				-- Type "NONE".
			create none_type.make (Void, none_class.name, none_class)
				-- Type "STRING".
			create string_type.make (Void, string_class.name, string_class)
				-- Type "ARRAY [ANY]".
			create a_parameters.make_with_capacity (1)
			a_parameters.put_first (any_class)
			create array_any_type.make (Void, array_class.name, a_parameters, array_class)
				-- Type "ARRAY [NONE]".
			create a_parameters.make_with_capacity (1)
			a_parameters.put_first (none_class)
			create array_none_type.make (Void, array_class.name, a_parameters, array_class)
				-- Implicit parent "ANY".
			create any_parent.make (any_type, Void, Void, Void, Void, Void)
			create any_parents.make_with_capacity (1)
			any_parents.put_first (any_parent)
				-- Built-in conversion features.
			create integer_8_convert_feature.make (integer_8_class)
			create integer_16_convert_feature.make (integer_16_class)
			create integer_convert_feature.make (integer_class)
			create integer_64_convert_feature.make (integer_64_class)
			create real_convert_feature.make (real_class)
			create double_convert_feature.make (double_class)
		ensure
			any_class_not_void: any_class /= Void
			general_class_not_void: general_class /= Void
			none_class_not_void: none_class /= Void
			tuple_class_not_void: tuple_class /= Void
			bit_class_not_void: bit_class /= Void
			string_class_not_void: string_class /= Void
			array_class_not_void: array_class /= Void
			boolean_class_not_void: boolean_class /= Void
			character_class_not_void: character_class /= Void
			wide_character_class_not_void: wide_character_class /= Void
			integer_class_not_void: integer_class /= Void
			integer_8_class_not_void: integer_8_class /= Void
			integer_16_class_not_void: integer_16_class /= Void
			integer_64_class_not_void: integer_64_class /= Void
			real_class_not_void: real_class /= Void
			double_class_not_void: double_class /= Void
			pointer_class_not_void: pointer_class /= Void
			typed_pointer_class_not_void: typed_pointer_class /= Void
			procedure_class_not_void: procedure_class /= Void
			predicate_class_not_void: predicate_class /= Void
			function_class_not_void: function_class /= Void
			unknown_class_not_void: unknown_class /= Void
			any_type_not_void: any_type /= Void
			string_type_not_void: string_type /= Void
			none_type_not_void: none_type /= Void
			array_any_type_not_void: array_any_type /= Void
			array_none_type_not_void: array_none_type /= Void
			any_parent_not_void: any_parent /= Void
			any_parents_not_void: any_parents /= Void
			integer_8_convert_feature_not_void: integer_8_convert_feature /= Void
			integer_16_convert_feature_not_void: integer_16_convert_feature /= Void
			integer_convert_feature_not_void: integer_convert_feature /= Void
			integer_64_convert_feature_not_void: integer_64_convert_feature /= Void
			real_convert_feature_not_void: real_convert_feature /= Void
			double_convert_feature_not_void: double_convert_feature /= Void
		end

feature -- Status report

	has_class (a_name: ET_CLASS_NAME): BOOLEAN is
			-- Is there a class named `a_name'
			-- in current universe?
		require
			a_name_not_void: a_name /= Void
		do
			classes.search (a_name)
			if classes.found then
				Result := classes.found_item.is_preparsed
			end
		ensure
			is_preparsed: Result implies eiffel_class (a_name).is_preparsed
		end

	is_preparsed: BOOLEAN
			-- Has the whole universe already been preparsed?

feature -- Access

	clusters: ET_CLUSTERS
			-- Clusters

	root_class: ET_CLASS
			-- Root class

	root_creation: ET_FEATURE_NAME
			-- Root creation procedure

	system_name: STRING
			-- Name of system

	classes: DS_HASH_TABLE [ET_CLASS, ET_CLASS_NAME]
			-- Classes in universe

	class_by_name (a_name: STRING): ET_CLASS is
			-- Class named `a_name' in universe;
			-- Void if not such class
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: a_name.count > 0
		local
			a_class_name: ET_IDENTIFIER
		do
			create a_class_name.make (a_name)
			classes.search (a_class_name)
			if classes.found then
				Result := classes.found_item
			end
		end

	eiffel_class (a_name: ET_CLASS_NAME): ET_CLASS is
			-- Class named `a_name' in universe;
			-- add this class to universe if not found
		require
			a_name_not_void: a_name /= Void
		do
			classes.search (a_name)
			if classes.found then
				Result := classes.found_item
			else
				Result := ast_factory.new_class (a_name, classes.count + 1)
				classes.force_last (Result, a_name)
			end
		ensure
			eiffel_class_not_void: Result /= Void
		end

	error_handler: ET_ERROR_HANDLER
			-- Error handler

	ast_factory: ET_AST_FACTORY
			-- Abstract Syntax Tree factory

feature -- Basic classes

	any_class: ET_CLASS
			-- Class "ANY"

	general_class: ET_CLASS
			-- Class "GENERAL"

	none_class: ET_CLASS
			-- Class "NONE"

	tuple_class: ET_CLASS
			-- Class "TUPLE"

	bit_class: ET_CLASS
			-- Class "BIT"

	string_class: ET_CLASS
			-- Class "STRING"

	array_class: ET_CLASS
			-- Class "ARRAY"

	boolean_class: ET_CLASS
			-- Class "BOOLEAN"

	character_class: ET_CLASS
			-- Class "CHARACTER"

	wide_character_class: ET_CLASS
			-- Class "WIDE_CHARACTER"

	integer_class: ET_CLASS
			-- Class "INTEGER"

	integer_8_class: ET_CLASS
			-- Class "INTEGER_8"

	integer_16_class: ET_CLASS
			-- Class "INTEGER_16"

	integer_64_class: ET_CLASS
			-- Class "INTEGER_64"

	real_class: ET_CLASS
			-- Class "REAL"

	double_class: ET_CLASS
			-- Class "DOUBLE"

	pointer_class: ET_CLASS
			-- Class "POINTER"

	typed_pointer_class: ET_CLASS
			-- Class "TYPED_POINTER"

	procedure_class: ET_CLASS
			-- Class "PROCEDURE"

	predicate_class: ET_CLASS
			-- Class "PREDICATE"

	function_class: ET_CLASS
			-- Class "FUNCTION"

	unknown_class: ET_CLASS
			-- Class "*UNKNOWN*"
			-- This class is equal to no other classes, not even itself;
			-- it does conform to no type, not even itself, and no type
			-- conforms to it

	any_type: ET_CLASS_TYPE
			-- Class type "ANY"

	none_type: ET_CLASS_TYPE
			-- Class type "NONE"

	string_type: ET_CLASS_TYPE
			-- Class type "STRING"

	array_any_type: ET_GENERIC_CLASS_TYPE
			-- Class type "ARRAY [ANY]"

	array_none_type: ET_GENERIC_CLASS_TYPE
			-- Class type "ARRAY [NONE]"

	any_parent: ET_PARENT
			-- Default parent

	any_parents: ET_PARENT_LIST
			-- Default parents

feature -- Feature access

	integer_8_convert_feature: ET_BUILTIN_CONVERT_FEATURE
			-- Built-in conversion feature to INTEGER_8

	integer_16_convert_feature: ET_BUILTIN_CONVERT_FEATURE
			-- Built-in conversion feature to INTEGER_16

	integer_convert_feature: ET_BUILTIN_CONVERT_FEATURE
			-- Built-in conversion feature to INTEGER

	integer_64_convert_feature: ET_BUILTIN_CONVERT_FEATURE
			-- Built-in conversion feature to INTEGER_64

	real_convert_feature: ET_BUILTIN_CONVERT_FEATURE
			-- Built-in conversion feature to REAL

	double_convert_feature: ET_BUILTIN_CONVERT_FEATURE
			-- Built-in conversion feature to DOUBLE

	default_create_seed: INTEGER
			-- Seed of feature 'default_create' in class ANY

	void_seed: INTEGER
			-- Seed of feature 'Void' in class ANY

feature -- Feature setting

	set_default_create_seed (a_seed: INTEGER) is
			-- Set `default_create_seed' to `a_seed'.
		require
			a_seed_non_negative: a_seed >= 0
		do
			default_create_seed := a_seed
		ensure
			default_create_seed_set: default_create_seed = a_seed
		end

	set_void_seed (a_seed: INTEGER) is
			-- Set `void_seed' to `a_seed'.
		require
			a_seed_non_negative: a_seed >= 0
		do
			void_seed := a_seed
		ensure
			void_seed_set: void_seed = a_seed
		end

	set_feature_seeds is
			-- Set kernel feature seeds.
		local
			a_feature: ET_FEATURE
		do
			a_feature := any_class.named_feature (tokens.default_create_feature_name)
			if a_feature /= Void then
				set_default_create_seed (a_feature.first_seed)
			else
				a_feature := general_class.named_feature (tokens.default_create_feature_name)
				if a_feature /= Void then
					set_default_create_seed (a_feature.first_seed)
				else
-- TODO
				end
			end
			a_feature := any_class.named_feature (tokens.void_feature_name)
			if a_feature /= Void then
				set_void_seed (a_feature.first_seed)
			else
				a_feature := general_class.named_feature (tokens.void_feature_name)
				if a_feature /= Void then
					set_void_seed (a_feature.first_seed)
				else
-- TODO
				end
			end
		end

feature -- Feature registration

	register_feature (a_feature: ET_FEATURE) is
			-- Register `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			feature_count := feature_count + 1
			a_feature.set_id (feature_count)
		ensure
			registered: a_feature.is_registered
		end

	feature_count: INTEGER
			-- Number of features already registered

feature -- Measurement

	parsed_classes_count: INTEGER is
			-- Number of parsed classes in universe
		local
			a_cursor: DS_HASH_TABLE_CURSOR [ET_CLASS, ET_CLASS_NAME]
		do
			a_cursor := classes.new_cursor
			from a_cursor.start until a_cursor.after loop
				if a_cursor.item.is_parsed then
					Result := Result + 1
				end
				a_cursor.forth
			end
		ensure
			parsed_classes_count_non_negative: Result >= 0
		end

	cluster_count: INTEGER is
			-- Number (recursively) of non-abstract clusters
		do
			if clusters /= Void then
				Result := clusters.count
			end
		ensure
			cluster_count_non_negavite: Result >= 0
		end

feature -- Setting

	set_root_class (a_name: ET_CLASS_NAME) is
			-- Set `root_class'.
		require
			a_name_not_void: a_name /= Void
		do
			root_class := eiffel_class (a_name)
			root_class.set_in_system (True)
		ensure
			root_class_not_void: root_class /= Void
			root_class_set: root_class.name.same_class_name (a_name)
		end

	set_root_creation (a_name: like root_creation) is
			-- Set `root_creation' to `a_name'.
		do
			root_creation := a_name
		ensure
			root_creation_set: root_creation = a_name
		end

	set_system_name (a_name: like system_name) is
			-- Set `system_name' to `a_name'.
		do
			system_name := a_name
		ensure
			system_name_set: system_name = a_name
		end

	set_clusters (a_clusters: like clusters) is
			-- Set `a_clusters' to `clusters'.
		do
			clusters := a_clusters
		ensure
			clusters_set: clusters = a_clusters
		end

	set_error_handler (a_handler: like error_handler) is
			-- Set `error_handler' to `a_handler'.
		require
			a_handler_not_void: a_handler /= Void
		do
			error_handler := a_handler
		ensure
			error_handler_set: error_handler = a_handler
		end

	set_ast_factory (a_factory: like ast_factory) is
			-- Set `ast_factory' to `a_factory'.
		require
			a_factory_not_void: a_factory /= Void
		do
			ast_factory := a_factory
		ensure
			ast_factory_set: ast_factory = a_factory
		end

feature -- Parser status report

	use_assign_keyword: BOOLEAN
			-- Should 'assign' be considered as
			-- a keyword (otherwise identifier)?

	use_attribute_keyword: BOOLEAN
			-- Should 'attribute' be considered as
			-- a keyword (otherwise identifier)?

	use_convert_keyword: BOOLEAN
			-- Should 'convert' be considered as
			-- a keyword (otherwise identifier)?

	use_create_keyword: BOOLEAN
			-- Should 'create' be considered as
			-- a keyword (otherwise identifier)?

	use_recast_keyword: BOOLEAN
			-- Should 'recast' be considered as
			-- a keyword (otherwise identifier)?

	use_reference_keyword: BOOLEAN
			-- Should 'reference' be considered as
			-- a keyword (otherwise identifier)?

	use_void_keyword: BOOLEAN
			-- Should 'void' be considered as
			-- a keyword (otherwise identifier)?

feature -- Parser setting

	set_use_assign_keyword (b: BOOLEAN) is
			-- Set `use_assign_keyword' to `b'.
		do
			use_assign_keyword := b
		ensure
			use_assign_keyword_set: use_assign_keyword = b
		end

	set_use_attribute_keyword (b: BOOLEAN) is
			-- Set `use_attribute_keyword' to `b'.
		do
			use_attribute_keyword := b
		ensure
			use_attribute_keyword_set: use_attribute_keyword = b
		end

	set_use_convert_keyword (b: BOOLEAN) is
			-- Set `use_convert_keyword' to `b'.
		do
			use_convert_keyword := b
		ensure
			use_convert_keyword_set: use_convert_keyword = b
		end

	set_use_create_keyword (b: BOOLEAN) is
			-- Set `use_create_keyword' to `b'.
		do
			use_create_keyword := b
		ensure
			use_create_keyword_set: use_create_keyword = b
		end

	set_use_recast_keyword (b: BOOLEAN) is
			-- Set `use_recast_keyword' to `b'.
		do
			use_recast_keyword := b
		ensure
			use_recast_keyword_set: use_recast_keyword = b
		end

	set_use_reference_keyword (b: BOOLEAN) is
			-- Set `use_reference_keyword' to `b'.
		do
			use_reference_keyword := b
		ensure
			use_reference_keyword_set: use_reference_keyword = b
		end

	set_use_void_keyword (b: BOOLEAN) is
			-- Set `use_void_keyword' to `b'.
		do
			use_void_keyword := b
		ensure
			use_void_keyword_set: use_void_keyword = b
		end

feature -- Element change

	add_implicit_subclusters is
			-- Add (recursively) implicit subclusters when clusters are recursive.
			-- Note that these subclusters will otherwise be added when running one of
			-- the `preparse_*' or `parse_all' routines.
		do
			if clusters /= Void then
				cluster_processor.add_implicit_subclusters_to_clusters (clusters)
			end
		end

feature -- Parsing

	preparse is
			-- Traverse all clusters and build a mapping between
			-- class names and filenames in each cluster. Classes
			-- are added to `classes', but are not parsed.
			-- Use `preparse_multiple' policy by default (this
			-- can be redefined in descendants).
		do
			preparse_multiple
		end

	preparse_shallow is
			-- Traverse all clusters and build a mapping between
			-- class names and filenames in each cluster. Classes
			-- are added to `classes', but are not parsed.
			-- Filenames are supposed to be of the form 'classname.e'.
		do
			if not is_preparsed then
				if clusters /= Void then
					cluster_processor.preparse_clusters_shallow (clusters)
				end
				is_preparsed := True
			end
		end

	preparse_single is
			-- Traverse all clusters and build a mapping between
			-- class names and filenames in each cluster. Classes
			-- are added to `classes', but are not parsed.
			-- Each Eiffel file is supposed to contain exactly
			-- one class.
		do
			if not is_preparsed then
				if clusters /= Void then
					cluster_processor.preparse_clusters_single (clusters)
				end
				is_preparsed := True
			end
		end

	preparse_multiple is
			-- Traverse all clusters and build a mapping between
			-- class names and filenames in each cluster. Classes
			-- are added to `classes', but are not parsed.
			-- Each Eiffel file can contain more than one class.
		do
			if not is_preparsed then
				if clusters /= Void then
					cluster_processor.preparse_clusters_multiple (clusters)
				end
				is_preparsed := True
			end
		end

	preparse_single_file (a_file: KI_CHARACTER_INPUT_STREAM; a_filename: STRING; a_cluster: ET_CLUSTER) is
			-- Scan Eiffel file `a_file' to find the name of the class it
			-- contains. The file is supposed to contain exactly one class.
			-- Add the class to `classes', but do not parse it.
			-- `a_filename' is the filename of `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_read: a_file.is_open_read
			a_filename_not_void: a_filename /= Void
			a_cluster_not_void: a_cluster /= Void
		do
			eiffel_preparser.preparse_single (a_file, a_filename, a_cluster)
		end

	preparse_multiple_file (a_file: KI_CHARACTER_INPUT_STREAM; a_filename: STRING; a_cluster: ET_CLUSTER) is
			-- Scan Eiffel file `a_file' to find the names of the classes
			-- it contains. The file can contain more than one class. Add
			-- the classes to `classes', but do not parse them.
			-- `a_filename' is the filename of `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_read: a_file.is_open_read
			a_filename_not_void: a_filename /= Void
			a_cluster_not_void: a_cluster /= Void
		do
			eiffel_preparser.preparse_multiple (a_file, a_filename, a_cluster)
		end

	parse_all is
			-- Parse whole universe.
			-- There is not need to call one of the preparse routines
			-- beforehand since the current routine will traverse all
			-- clusters and parse all Eiffel files anyway.
		do
			if clusters /= Void then
				cluster_processor.parse_clusters_all (clusters)
			end
			is_preparsed := True
		end

	parse_system is
			-- Parse whole system.
		local
			a_cursor: DS_HASH_TABLE_CURSOR [ET_CLASS, ET_CLASS_NAME]
			a_class: ET_CLASS
			not_done: BOOLEAN
			a_parser: like eiffel_parser
		do
			if root_class /= Void then
				a_parser := eiffel_parser
				root_class.process (a_parser)
				if not root_class.is_preparsed then
						-- TODO:
					print ("Class ")
					print (root_class.name.name)
					print (" not found.%N")
				else
					not_done := True
					a_cursor := classes.new_cursor
					from until not not_done loop
						not_done := False
						from a_cursor.start until a_cursor.after loop
							a_class := a_cursor.item
							if a_class.in_system and then not a_class.is_parsed then
								a_class.process (a_parser)
								not_done := True
							end
							a_cursor.forth
						end
					end
				end
			end
		end

	parse_file (a_file: KI_CHARACTER_INPUT_STREAM; a_filename: STRING; a_time_stamp: INTEGER; a_cluster: ET_CLUSTER) is
			-- Parse all classes in `a_file' within cluster `a_cluster'.
			-- `a_filename' is the filename of `a_file' and `a_time_stamp'
			-- its time stamp just before it was open.
		require
			a_file_not_void: a_file /= Void
			a_file_open_read: a_file.is_open_read
			a_filename_not_void: a_filename /= Void
			a_cluster_not_void: a_cluster /= Void
		do
			eiffel_parser.parse (a_file, a_filename, a_time_stamp, a_cluster)
		end

feature -- Compilation

	compile (flat: BOOLEAN) is
			-- Compile universe.
			-- `flat' means that the inherited features are checked
			-- again in the descendant classes during Degree 3.
		do
			if root_class = Void or root_class = none_class then
				compile_all (flat)
			else
				compile_system (flat)
			end
		end

	compile_system (flat: BOOLEAN) is
			-- Compile all classes in the system.
			-- `flat' means that the inherited features are checked
			-- again in the descendant classes during Degree 3.
		local
			l_clock: DT_SHARED_SYSTEM_CLOCK
			dt1: DT_DATE_TIME
			a_signature_viewer: ET_SIGNATURE_VIEWER
		do
			activate_processors
			debug ("ericb")
				create l_clock
				dt1 := l_clock.system_clock.date_time_now
			end
			preparse_single
			debug ("ericb")
				print_time (dt1, "Degree 6")
				dt1 := l_clock.system_clock.date_time_now
			end
			parse_system
			debug ("ericb")
				std.error.put_string ("Preparsed ")
				std.error.put_integer (classes.count)
				std.error.put_line (" classes")
				std.error.put_string ("Parsed ")
				std.error.put_integer (parsed_classes_count)
				std.error.put_line (" classes")
				std.error.put_integer (feature_count)
				std.error.put_line (" features")
			end
			debug ("ericb")
				print_time (dt1, "Degree 5")
				dt1 := l_clock.system_clock.date_time_now
			end
			if cat_enabled then
				compile_cat_calls
				debug ("ericb")
					print_time (dt1, "Degree CAT")
					dt1 := l_clock.system_clock.date_time_now
				end
			end
			if forget_enabled then
				compile_forget_features
				debug ("ericb")
					print_time (dt1, "Degree FORGET")
					dt1 := l_clock.system_clock.date_time_now
				end
			end
			compile_degree_4
			debug ("ericb")
				print_time (dt1, "Degree 4")
				dt1 := l_clock.system_clock.date_time_now
			end
			compile_degree_3 (flat)
			debug ("ericb")
				print_time (dt1, "Degree 3")
			end
			debug ("ericb")
				create a_signature_viewer.make (Current)
				a_signature_viewer.execute
			end
		end

	compile_all (flat: BOOLEAN) is
			-- Compile all classes in the universe.
			-- `flat' means that the inherited features are checked
			-- again in the descendant classes during Degree 3.
		local
			l_clock: DT_SHARED_SYSTEM_CLOCK
			dt1: DT_DATE_TIME
		do
			activate_processors
			debug ("ericb")
				create l_clock
				dt1 := l_clock.system_clock.date_time_now
			end
			parse_all
--			preparse_single
--			debug ("ericb")
--				print_time (dt1, "Degree 6")
--				dt1 := l_clock.system_clock.date_time_now
--			end
--			compile_degree_5
			debug ("ericb")
				print_time (dt1, "Degree 5")
				dt1 := l_clock.system_clock.date_time_now
			end
			if cat_enabled then
				compile_cat_calls
				debug ("ericb")
					print_time (dt1, "Degree CAT")
					dt1 := l_clock.system_clock.date_time_now
				end
			end
			if forget_enabled then
				compile_forget_features
				debug ("ericb")
					print_time (dt1, "Degree FORGET")
					dt1 := l_clock.system_clock.date_time_now
				end
			end
			compile_degree_4
			debug ("ericb")
				print_time (dt1, "Degree 4")
				dt1 := l_clock.system_clock.date_time_now
			end
			compile_degree_3 (flat)
			debug ("ericb")
				print_time (dt1, "Degree 3")
			end
		end

	compile_degree_5 is
			-- Equivalent of ISE's Degree 5.
		local
			a_parser: like eiffel_parser
			a_cursor: DS_HASH_TABLE_CURSOR [ET_CLASS, ET_CLASS_NAME]
			a_class: ET_CLASS
		do
				-- Parse classes.
			a_parser := eiffel_parser
			a_cursor := classes.new_cursor
			from a_cursor.start until a_cursor.after loop
				a_class := a_cursor.item
				if a_class.is_preparsed then
					a_class.process (a_parser)
				end
				a_cursor.forth
			end
			debug ("ericb")
				std.error.put_string ("Parsed ")
				std.error.put_integer (classes.count)
				std.error.put_line (" classes")
				std.error.put_integer (feature_count)
				std.error.put_line (" features")
			end
		end

	compile_degree_4 is
			-- Equivalent of ISE Eiffel's Degree 4.
		local
			a_cursor: DS_HASH_TABLE_CURSOR [ET_CLASS, ET_CLASS_NAME]
			a_class: ET_CLASS
			nb: INTEGER
		do
			set_feature_seeds
				-- Build ancestors.
			a_cursor := classes.new_cursor
			from a_cursor.start until a_cursor.after loop
				a_class := a_cursor.item
				if a_class.is_parsed then
					a_class.process (ancestor_builder)
				end
				a_cursor.forth
			end
				-- Flatten features.
			from a_cursor.start until a_cursor.after loop
				a_class := a_cursor.item
				if a_class.ancestors_built then
					nb := nb + 1
					a_class.process (feature_flattener)
				end
				a_cursor.forth
			end
				-- Resolve qualified anchored types in signatures.
			from a_cursor.start until a_cursor.after loop
				a_class := a_cursor.item
				if a_class.features_flattened then
					a_class.process (qualified_signature_resolver)
				end
				a_cursor.forth
			end
				-- Check interface.
			from a_cursor.start until a_cursor.after loop
				a_class := a_cursor.item
				if a_class.qualified_signatures_resolved then
					a_class.process (interface_checker)
				end
				a_cursor.forth
			end
			debug ("ericb")
				std.error.put_string ("Flattened ")
				std.error.put_integer (nb)
				std.error.put_line (" classes")
				std.error.put_integer (feature_count)
				std.error.put_line (" features")
			end
		end

	compile_degree_3 (flat: BOOLEAN) is
			-- Equivalent of ISE Eiffel's Degree 3.
			-- `flat' means that the inherited features are checked
			-- again in the descendant classes.
		local
			a_cursor: DS_HASH_TABLE_CURSOR [ET_CLASS, ET_CLASS_NAME]
			a_class: ET_CLASS
			a_checker: ET_IMPLEMENTATION_CHECKER
		do
				-- Check implementation.
			a_checker ?= implementation_checker
			if a_checker /= Void then
				a_checker.set_flat_mode (flat)
			end
			a_cursor := classes.new_cursor
			from a_cursor.start until a_cursor.after loop
				a_class := a_cursor.item
				if a_class.interface_checked then
					a_class.process (implementation_checker)
				end
				a_cursor.forth
			end
		end

feature -- Client/Supplier relationship

	report_expression_supplier (a_supplier: ET_TYPE_CONTEXT; a_client: ET_BASE_TYPE; a_feature: ET_FEATURE) is
			-- Report the fact that `a_supplier' is the type of an expression
			-- in feature `a_feature' in type `a_client'.
			-- (Note that `a_supplier' may be altered after the execution of
			-- this routine. Therefore if you want to keep a reference to it
			-- you should duplicate it or use its base type for example.)
		require
			a_supplier_not_void: a_supplier /= Void
			a_supplier_valid: a_supplier.is_valid_context
			a_client_not_void: a_client /= Void
			a_client_valid: a_client.is_valid_context
			a_feature_not_void: a_feature /= Void
		do
			if supplier_handler /= Void then
				supplier_handler.report_expression_supplier (a_supplier, a_client, a_feature)
			end
		end

	report_argument_supplier (a_supplier: ET_TYPE; a_client: ET_BASE_TYPE; a_feature: ET_FEATURE) is
			-- Report the fact that `a_supplier' is the type of a formal
			-- argument of feature `a_feature' in type `a_client'.
			-- (Note that `a_supplier' is assumed to be interpreted in
			-- the context of `a_client'.)
		require
			a_supplier_not_void: a_supplier /= Void
			a_client_not_void: a_client /= Void
			a_client_valid: a_client.is_valid_context
			a_feature_not_void: a_feature /= Void
		do
			if supplier_handler /= Void then
				supplier_handler.report_argument_supplier (a_supplier, a_client, a_feature)
			end
		end

	report_result_supplier (a_supplier: ET_TYPE; a_client: ET_BASE_TYPE; a_feature: ET_FEATURE) is
			-- Report the fact that `a_supplier' is the type of the
			-- result of query `a_feature' in type `a_client'.
			-- (Note that `a_supplier' is assumed to be interpreted in
			-- the context of `a_client'.)
		require
			a_supplier_not_void: a_supplier /= Void
			a_client_not_void: a_client /= Void
			a_client_valid: a_client.is_valid_context
			a_feature_not_void: a_feature /= Void
		do
			if supplier_handler /= Void then
				supplier_handler.report_result_supplier (a_supplier, a_client, a_feature)
			end
		end

	report_static_supplier (a_supplier: ET_TYPE; a_client: ET_BASE_TYPE; a_feature: ET_FEATURE) is
			-- Report the fact that `a_supplier' is the type of a
			-- static call in `a_feature' in type `a_client'.
			-- (Note that `a_supplier' is assumed to be interpreted in
			-- the context of `a_client'.)
		require
			a_supplier_not_void: a_supplier /= Void
			a_client_not_void: a_client /= Void
			a_client_valid: a_client.is_valid_context
			a_feature_not_void: a_feature /= Void
		do
			if supplier_handler /= Void then
				supplier_handler.report_static_supplier (a_supplier, a_client, a_feature)
			end
		end

	report_create_supplier (a_supplier: ET_TYPE; a_client: ET_BASE_TYPE; a_feature: ET_FEATURE) is
			-- Report the fact that `a_supplier' is the explicit type of a creation
			-- instruction or expression in `a_feature' in type `a_client'.
			-- (Note that `a_supplier' is assumed to be interpreted in
			-- the context of `a_client'.)
		require
			a_supplier_not_void: a_supplier /= Void
			a_client_not_void: a_client /= Void
			a_client_valid: a_client.is_valid_context
			a_feature_not_void: a_feature /= Void
		do
			if supplier_handler /= Void then
				supplier_handler.report_create_supplier (a_supplier, a_client, a_feature)
			end
		end

	report_local_supplier (a_supplier: ET_TYPE; a_client: ET_BASE_TYPE; a_feature: ET_FEATURE) is
			-- Report the fact that `a_supplier' is the type of a
			-- local variable of feature `a_feature' in type `a_client'.
			-- (Note that `a_supplier' is assumed to be interpreted in
			-- the context of `a_feature.implementation_class'. Its
			-- formal generic parameters should be resolved in the
			-- base class of `a_client' first before using `a_client'
			-- as its context.)
		require
			a_supplier_not_void: a_supplier /= Void
			a_client_not_void: a_client /= Void
			a_client_valid: a_client.is_valid_context
			a_feature_not_void: a_feature /= Void
		do
			if supplier_handler /= Void then
				supplier_handler.report_local_supplier (a_supplier, a_client, a_feature)
			end
		end

	supplier_handler: ET_SUPPLIER_HANDLER
			-- Supplier handler

	set_supplier_handler (a_handler: like supplier_handler) is
			-- Set `supplier_handler' to `a_handler'.
		do
			supplier_handler := a_handler
		ensure
			supplier_handler_set: supplier_handler = a_handler
		end

feature -- CAT-calls

	cat_enabled: BOOLEAN
			-- Is CAT-call processing enabled?

	set_cat_enabled (b: BOOLEAN) is
			-- Set `cat_enabled' to `b'.
		do
			cat_enabled := b
		ensure
			cat_enabled_set: cat_enabled = b
		end

	all_cat_features: BOOLEAN
			-- Are all features considered as 'cat'?

	anchored_cat_features: BOOLEAN
			-- Are features with argument types containing anchored types
			-- considered as 'cat'?

	set_anchored_cat_features (b: BOOLEAN) is
			-- Set `anchored_cat_features' to `b'.
		do
			anchored_cat_features := b
		ensure
			anchored_cat_features_set: anchored_cat_features = b
		end

	searching_cat_features: BOOLEAN
			-- Are we currently searching for 'cat' features?

	cat_feature_count: INTEGER
			-- Number of 'cat' features found

	set_cat_feature_count (i: INTEGER) is
			-- Set `cat_feature_count' to `i'.
		do
			cat_feature_count := i
		ensure
			cat_feature_count_set: cat_feature_count = i
		end

	searching_dog_types: BOOLEAN
			-- Are we currently searching for 'dog' types?

	dog_type_count: INTEGER
			-- Number of 'dog' types found

	set_dog_type_count (i: INTEGER) is
			-- Set `dog_type_count' to `i'.
		do
			dog_type_count := i
		ensure
			dog_type_count_set: dog_type_count = i
		end

	compile_cat_calls is
			-- Process CAT-calls.
		require
			cat_enabled: cat_enabled
		local
			a_cursor: DS_HASH_TABLE_CURSOR [ET_CLASS, ET_CLASS_NAME]
			a_class: ET_CLASS
			old_feature_count: INTEGER
			nb_cat: INTEGER
			i, nb: INTEGER
			j, nb2: INTEGER
			k, nb3: INTEGER
			an_ancestors: ET_BASE_TYPE_LIST
			an_ancestor: ET_CLASS
			a_features: ET_FEATURE_LIST
			a_feature: ET_FEATURE
			a_cat_feature: ET_FEATURE
			a_seeds: ET_FEATURE_IDS
		do
			old_feature_count := feature_count
				-- Find 'dog' types.
			a_cursor := classes.new_cursor
			all_cat_features := True
			searching_dog_types := True
			from dog_type_count := 1 until dog_type_count = 0 loop
				dog_type_count := 0
				compile_degree_4
				compile_degree_3 (False)
					-- Rewind processing to just after parsing.
				from a_cursor.start until a_cursor.after loop
					a_class := a_cursor.item
					a_class.reset_implementation_checked
					a_class.reset_interface_checked
					a_class.reset_qualified_signatures_resolved
					a_class.reset_features_flattened
					a_class.reset_ancestors_built
					a_cursor.forth
				end
				feature_count := old_feature_count
				debug ("ericb")
					std.error.put_string ("DOG type count = ")
					std.error.put_integer (dog_type_count)
					std.error.put_new_line
					debug ("stop")
						io.read_line
					end
				end
			end
			all_cat_features := False
			searching_dog_types := False
			searching_cat_features := True
			from cat_feature_count := 1 until cat_feature_count = 0 loop
				cat_feature_count := 0
					-- Build ancestors.
				from a_cursor.start until a_cursor.after loop
					a_class := a_cursor.item
					if a_class.is_parsed then
						a_class.process (ancestor_builder)
					end
					a_cursor.forth
				end
					-- Find 'cat' features.
				from a_cursor.start until a_cursor.after loop
					a_class := a_cursor.item
					if a_class.ancestors_built then
						a_class.process (feature_flattener)
					end
					a_cursor.forth
				end
				from nb_cat := 1 until nb_cat = 0 loop
					nb_cat := 0
					from a_cursor.start until a_cursor.after loop
						a_class := a_cursor.item
						if a_class.ancestors_built then
							an_ancestors := a_class.ancestors
							a_features := a_class.features
							nb := a_features.count
							nb2 := an_ancestors.count
							from i := 1 until i > nb loop
								a_feature := a_features.item (i)
								if a_feature.is_cat then
									from j := 1 until j > nb2 loop
										an_ancestor := an_ancestors.item (j).direct_base_class (Current)
										a_cat_feature := an_ancestor.seeded_feature (a_feature.first_seed)
										if a_cat_feature /= Void and then not a_cat_feature.is_cat then
											a_cat_feature.set_cat_keyword (tokens.cat_keyword)
											cat_feature_count := cat_feature_count + 1
											nb_cat := nb_cat + 1
										end
										a_seeds := a_feature.other_seeds
										if a_seeds /= Void then
											nb3 := a_seeds.count
											from k := 1 until k > nb3 loop
												a_cat_feature := an_ancestor.seeded_feature (a_seeds.item (k))
												if a_cat_feature /= Void and then not a_cat_feature.is_cat then
													a_cat_feature.set_cat_keyword (tokens.cat_keyword)
													cat_feature_count := cat_feature_count + 1
													nb_cat := nb_cat + 1
												end
												k := k + 1
											end
										end
										j := j + 1
									end
								end
								i := i + 1
							end
						end
						a_cursor.forth
					end
				end
					-- Rewind processing to just after parsing.
				from a_cursor.start until a_cursor.after loop
					a_class := a_cursor.item
					a_class.reset_implementation_checked
					a_class.reset_interface_checked
					a_class.reset_qualified_signatures_resolved
					a_class.reset_features_flattened
					a_class.reset_ancestors_built
					a_cursor.forth
				end
				feature_count := old_feature_count
				debug ("ericb")
					std.error.put_string ("CAT feature count = ")
					std.error.put_integer (cat_feature_count)
					std.error.put_new_line
					debug ("stop")
						io.read_line
					end
				end
			end
			searching_cat_features := False
		end

feature -- Forget features

	forget_enabled: BOOLEAN
			-- Is forget feature processing enabled?

	set_forget_enabled (b: BOOLEAN) is
			-- Set `forget_enabled' to `b'.
		do
			forget_enabled := b
		ensure
			forget_enabled_set: forget_enabled = b
		end

	all_forget_features: BOOLEAN
			-- Are all features considered as 'forget'?

	searching_forget_features: BOOLEAN
			-- Are we currently searching for 'forget' features?

	forget_feature_count: INTEGER
			-- Number of 'forget' features found

	set_forget_feature_count (i: INTEGER) is
			-- Set `forget_feature_count' to `i'.
		do
			forget_feature_count := i
		ensure
			forget_feature_count_set: forget_feature_count = i
		end

	compile_forget_features is
			-- Process 'forget' features.
		require
			forget_enabled: forget_enabled
		local
			a_cursor: DS_HASH_TABLE_CURSOR [ET_CLASS, ET_CLASS_NAME]
			a_class: ET_CLASS
			old_feature_count: INTEGER
		do
			old_feature_count := feature_count
				-- Find 'forget' features.
			a_cursor := classes.new_cursor
			searching_forget_features := True
			from forget_feature_count := 1 until forget_feature_count = 0 loop
				forget_feature_count := 0
				compile_degree_4
				compile_degree_3 (False)
					-- Rewind processing to just after parsing.
				from a_cursor.start until a_cursor.after loop
					a_class := a_cursor.item
					a_class.reset_implementation_checked
					a_class.reset_interface_checked
					a_class.reset_qualified_signatures_resolved
					a_class.reset_features_flattened
					a_class.reset_ancestors_built
					a_cursor.forth
				end
				feature_count := old_feature_count
				debug ("ericb")
					std.error.put_string ("Forget feature count = ")
					std.error.put_integer (forget_feature_count)
					std.error.put_new_line
					debug ("stop")
						io.read_line
					end
				end
			end
			searching_forget_features := False
		end

feature -- Processors

	cluster_processor: ET_CLUSTER_PROCESSOR
			-- Cluster processor

	eiffel_preparser: ET_EIFFEL_PREPARSER is
			-- Eiffel preparser
		do
			Result := internal_eiffel_preparser
			if Result = Void then
				create Result.make_with_factory (Current, ast_factory, error_handler)
				internal_eiffel_preparser := Result
			end
			Result.set_use_assign_keyword (use_assign_keyword)
			Result.set_use_attribute_keyword (use_attribute_keyword)
			Result.set_use_convert_keyword (use_convert_keyword)
			Result.set_use_create_keyword (use_create_keyword)
			Result.set_use_recast_keyword (use_recast_keyword)
			Result.set_use_reference_keyword (use_reference_keyword)
			Result.set_use_void_keyword (use_void_keyword)
		ensure
			eiffel_preparser_not_void: Result /= Void
		end

	eiffel_parser: ET_EIFFEL_PARSER is
			-- Eiffel parser
		do
			Result := internal_eiffel_parser
			if Result = Void then
				create Result.make_with_factory (Current, ast_factory, error_handler)
				internal_eiffel_parser := Result
			end
			Result.set_universe (Current)
			Result.set_ast_factory (ast_factory)
			Result.set_error_handler (error_handler)
			Result.set_use_assign_keyword (use_assign_keyword)
			Result.set_use_attribute_keyword (use_attribute_keyword)
			Result.set_use_convert_keyword (use_convert_keyword)
			Result.set_use_create_keyword (use_create_keyword)
			Result.set_use_recast_keyword (use_recast_keyword)
			Result.set_use_reference_keyword (use_reference_keyword)
			Result.set_use_void_keyword (use_void_keyword)
		ensure
			eiffel_parser_not_void: Result /= Void
		end

	ancestor_builder: ET_AST_PROCESSOR
			-- Ancestor builder

	feature_flattener: ET_AST_PROCESSOR
			-- Feature flattener

	qualified_signature_resolver: ET_AST_PROCESSOR
			-- Qualified signature resolver

	interface_checker: ET_AST_PROCESSOR
			-- Interface checker

	implementation_checker: ET_AST_PROCESSOR
			-- Implementation checker

	null_processor: ET_AST_NULL_PROCESSOR
			-- Null processor

	activate_processors is
			-- Activate processors.
		local
			l_feature_flattener: ET_FEATURE_FLATTENER
			l_interface_checker: ET_INTERFACE_CHECKER
		do
			if cat_enabled then
				all_cat_features := False
				any_type.set_cat_keyword (Void)
				none_type.set_cat_keyword (tokens.cat_keyword)
				string_type.set_cat_keyword (tokens.cat_keyword)
				array_any_type.set_cat_keyword (tokens.cat_keyword)
				array_none_type.set_cat_keyword (tokens.cat_keyword)
			else
				all_cat_features := True
				any_type.set_cat_keyword (Void)
				none_type.set_cat_keyword (Void)
				string_type.set_cat_keyword (Void)
				array_any_type.set_cat_keyword (Void)
				array_none_type.set_cat_keyword (Void)
			end
			if ancestor_builder = null_processor then
				create {ET_ANCESTOR_BUILDER} ancestor_builder.make (Current)
			end
			if feature_flattener = null_processor then
				create l_feature_flattener.make (Current)
				if forget_enabled then
					l_feature_flattener.set_conformance_checked (False)
				end
				feature_flattener := l_feature_flattener
			end
			if qualified_signature_resolver = null_processor then
				create {ET_QUALIFIED_SIGNATURE_RESOLVER} qualified_signature_resolver.make (Current)
			end
			if interface_checker = null_processor then
				create l_interface_checker.make (Current)
				if forget_enabled then
					l_interface_checker.set_conformance_checked (True)
				end
				interface_checker := l_interface_checker
			end
			if implementation_checker = null_processor then
				create {ET_IMPLEMENTATION_CHECKER} implementation_checker.make (Current)
			end
		end

	set_qualified_signature_resolver (a_resolver: like qualified_signature_resolver) is
			-- Set `qualified_signature_resolver' to `a_resolver'.
		require
			a_resolver_not_void: a_resolver /= Void
		do
			qualified_signature_resolver := a_resolver
		ensure
			qualified_signature_resolver_not_void: qualified_signature_resolver = a_resolver
		end

feature -- Timing

	print_time (a_start: DT_DATE_TIME; a_degree: STRING) is
			-- Print time spent in `a_degree' since `a_start'.
		require
			a_start_not_void: a_start /= Void
			a_degree_not_void: a_degree /= Void
		local
			l_clock: DT_SHARED_SYSTEM_CLOCK
			dt2: DT_DATE_TIME
			dtd: DT_DATE_TIME_DURATION
		do
			create l_clock
			dt2 := l_clock.system_clock.date_time_now
			dtd := dt2 - a_start
			dtd.set_canonical (a_start)
			std.error.put_string (a_degree)
			std.error.put_string (": ")
			std.error.put_line (dtd.out)
			debug ("stop")
				io.read_line
			end
		end

feature {NONE} -- Implementation

	internal_eiffel_preparser: ET_EIFFEL_PREPARSER
			-- Eiffel preparser

	internal_eiffel_parser: ET_EIFFEL_PARSER
			-- Eiffel parser

invariant

	classes_not_void: classes /= Void
	no_void_class: not classes.has_item (Void)
	error_handler_not_void: error_handler /= Void
	ast_factory_not_void: ast_factory /= Void
	any_class_not_void: any_class /= Void
	general_class_not_void: general_class /= Void
	none_class_not_void: none_class /= Void
	tuple_class_not_void: tuple_class /= Void
	bit_class_not_void: bit_class /= Void
	string_class_not_void: string_class /= Void
	array_class_not_void: array_class /= Void
	boolean_class_not_void: boolean_class /= Void
	character_class_not_void: character_class /= Void
	wide_character_class_not_void: wide_character_class /= Void
	integer_class_not_void: integer_class /= Void
	integer_8_class_not_void: integer_8_class /= Void
	integer_16_class_not_void: integer_16_class /= Void
	integer_64_class_not_void: integer_64_class /= Void
	real_class_not_void: real_class /= Void
	double_class_not_void: double_class /= Void
	pointer_class_not_void: pointer_class /= Void
	typed_pointer_class_not_void: typed_pointer_class /= Void
	procedure_class_not_void: procedure_class /= Void
	predicate_class_not_void: predicate_class /= Void
	function_class_not_void: function_class /= Void
	unknown_class_not_void: unknown_class /= Void
	any_type_not_void: any_type /= Void
	none_type_not_void: none_type /= Void
	string_type_not_void: string_type /= Void
	array_any_type_not_void: array_any_type /= Void
	array_none_type_not_void: array_none_type /= Void
	any_parent_not_void: any_parent /= Void
	any_parents_not_void: any_parents /= Void
	integer_8_convert_feature_not_void: integer_8_convert_feature /= Void
	integer_16_convert_feature_not_void: integer_16_convert_feature /= Void
	integer_convert_feature_not_void: integer_convert_feature /= Void
	integer_64_convert_feature_not_void: integer_64_convert_feature /= Void
	real_convert_feature_not_void: real_convert_feature /= Void
	double_convert_feature_not_void: double_convert_feature /= Void
	default_create_seed_non_negative: default_create_seed >= 0
	void_seed_non_negative: void_seed >= 0
	cluster_processor_not_void: cluster_processor /= Void
	ancestor_builder_not_void: ancestor_builder /= Void
	feature_flattener_not_void: feature_flattener /= Void
	qualified_signature_resolver_not_void: qualified_signature_resolver /= Void
	interface_checker_not_void: interface_checker /= Void
	implementation_checker_not_void: implementation_checker /= Void
	null_processor_not_void: null_processor /= Void

end
