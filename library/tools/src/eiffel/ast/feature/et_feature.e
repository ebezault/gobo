﻿note

	description:

		"Eiffel features"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2025, Eric Bezault and others"
	license: "MIT License"

deferred class ET_FEATURE

inherit

	ET_FLATTENED_FEATURE
		rename
			is_immediate as is_flattened_immediate,
			is_redeclared as is_flattened_redeclared,
			is_adapted as is_flattened_adapted,
			is_inherited as is_flattened_inherited,
			immediate_feature as flattened_immediate_feature,
			redeclared_feature as flattened_redeclared_feature,
			adapted_feature as flattened_adapted_feature,
			inherited_feature as flattened_inherited_feature
		redefine
			is_flattened_immediate,
			flattened_immediate_feature
		end

	ET_STANDALONE_CLOSURE
		undefine
			first_seed,
			other_seeds,
			has_seed
		redefine
			is_feature,
			as_feature,
			first_note,
			is_static
		end

feature -- Initialization

	reset
			-- Reset current feature as it was just after it was last parsed.
		do
			name.reset
			first_seed := id
			other_seeds := Void
			version := id
			first_precursor := Void
			other_precursors := Void
			if attached type as l_type then
				l_type.reset
			end
			if attached arguments as l_arguments then
				l_arguments.reset
			end
			reset_after_features_flattened
		end

	reset_after_features_flattened
			-- Reset current feature as it was just after it was last flattened.
		do
			reset_after_interface_checked
			reset_signature_qualified_anchored_types
		end

	reset_after_interface_checked
			-- Reset current feature as it was just after its interface was last checked.
		do
			if attached preconditions as l_preconditions then
				l_preconditions.reset
			end
			if attached postconditions as l_postconditions then
				l_postconditions.reset
			end
			reset_validity_checked
		end

	reset_signature_qualified_anchored_types
			-- Reset qualified anchored types contained in signature of
			-- current feature as they were just after they were last parsed.
		do
			if attached type as l_type then
				l_type.reset_qualified_anchored_types
			end
			if attached arguments as l_arguments then
				l_arguments.reset_qualified_anchored_types
			end
		end

feature -- Access

	name: ET_FEATURE_NAME
			-- Feature name
		do
			Result := extended_name.feature_name
		end

	lower_name: STRING
			-- Lower-name of feature
			-- (May return the same object as `name.name' if already in lower case,
			-- otherwise return a new object at each call.)
		do
			Result := name.lower_name
		ensure then
			definition: Result.is_equal (name.name.as_lower)
		end

	alias_names: detachable ET_ALIAS_NAME_LIST
			-- Alias names, if any
		do
			Result := extended_name.alias_names
		end

	extended_name: ET_EXTENDED_FEATURE_NAME
			-- Extended feature name (possibly followed by comma for synomyms)

	overloaded_extended_name: ET_EXTENDED_FEATURE_NAME
			-- Possibly overloaded extended Eiffel feature name
			-- (useful in .NET)
		do
			Result := extended_name
		ensure
			overloaded_extended_name_not_void: Result /= Void
		end

	overloaded_name: ET_FEATURE_NAME
			-- Possibly overloaded Eiffel feature name
			-- (useful in .NET)
		do
			Result := overloaded_extended_name.feature_name
		ensure
			overloaded_name_not_void: Result /= Void
		end

	overloaded_alias_names: detachable ET_ALIAS_NAME_LIST
			-- Possibly overloaded Eiffel alias names, if any
			-- (useful in .NET)
		do
			Result := overloaded_extended_name.alias_names
		end

	header_break: detachable ET_BREAK
			-- Break which appears where the header comment is expected
		deferred
		end

	obsolete_message: detachable ET_OBSOLETE
			-- Obsolete message
		do
		end

	first_note: detachable ET_NOTE_LIST
			-- Note clause at the beginning of the feature

	id: INTEGER
			-- Feature ID

	version: INTEGER
			-- Version (feature ID of last declaration
			-- of current feature)

	first_precursor: detachable ET_FEATURE
			-- First precursor;
			-- Void if the feature has no precursor.
			-- Useful to build the flat preconditions and
			-- postconditions of the feature.

	other_precursors: detachable ET_FEATURE_LIST
			-- Other precursors (Features from which the current
			-- feature gets parts of its preconditions and
			-- postconditions from its parents. Note that because
			-- of replication all the seeds of the precursors are not
			-- necessarily a subset of the seeds of current feature;
			-- May be Void if there is only one precursor (which is
			-- then accessible through `first_precursor') or no
			-- precursor. There can be several precursors if the
			-- current feature is the result of a merge or join of
			-- several features in the inheritance clause.

	implementation_class: ET_CLASS
			-- Class where implementation of current feature
			-- has been provided;
			-- Useful for interpreting feature calls and type
			-- anchors (that might be renamed in descendant classes)
			-- when feature is inherited as-is.
			-- Note that the signature has already been resolved
			-- in the context of the current class.

	implementation_feature: ET_FEATURE
			-- Current feature in `implementation_class',
			-- Useful for interpreting feature calls and type
			-- anchors (that might be renamed in descendant classes)
			-- when feature is inherited as-is.
			-- Note that the signature has already been resolved
			-- in the context of the current class.

	frozen_keyword: detachable ET_KEYWORD
			-- 'frozen' keyword

	feature_clause: detachable ET_FEATURE_CLAUSE
			-- Feature clause containing current feature

	semicolon: detachable ET_SEMICOLON_SYMBOL
			-- Optional semicolon in semicolon-separated list of features

	synonym: detachable ET_FEATURE
			-- Next synonym if any

	hash_code: INTEGER
			-- Hash code value

	position: ET_POSITION
			-- Position of first character of
			-- current node in source code
		do
			if attached frozen_keyword as l_frozen_keyword then
				Result := l_frozen_keyword.position
				if Result.is_null then
					Result := extended_name.position
				end
			else
				Result := extended_name.position
			end
		end

	first_leaf: ET_AST_LEAF
			-- First leaf node in current node
		do
			if attached frozen_keyword as l_frozen_keyword then
				Result := l_frozen_keyword
			else
				Result := extended_name.first_leaf
			end
		end

feature -- Status report

	is_registered: BOOLEAN
			-- Has feature been registered to the surrounding universe?
		do
			Result := (id > 0)
		ensure
			definition: Result = (id > 0)
		end

	has_header_comment: BOOLEAN
			-- Does current feature have a header comment?
		do
			if attached header_break as l_break then
				Result := l_break.has_comment
			end
		end

	has_non_empty_header_comment: BOOLEAN
			-- Does current feature have a non-empty header comment?
			-- (Comments only made up of white characters or minus signs are not taken into account.)
		do
			if attached header_break as l_break then
				Result := l_break.has_non_empty_comment
			end
		end

	is_frozen: BOOLEAN
			-- Has feature been declared as frozen?
		do
			Result := (frozen_keyword /= Void)
		end

	is_deferred: BOOLEAN
			-- Is feature deferred?
		do
			-- Result := False
		end

	is_external: BOOLEAN
			-- Is feature external?
		do
			-- Result := False
		end

	is_creation_procedure (a_class: ET_CLASS; a_system_processor: ET_SYSTEM_PROCESSOR): BOOLEAN
			-- Is current feature a creation procedure in `a_class'?
			-- (Note: Use `a_system_processor.feature_flattener' on `a_class' if needed
			-- to determine whether current feature is the version of 'default_create'
			-- in `a_class'.)
		require
			a_class_not_void: a_class /= Void
			a_system_processor_not_void: a_system_processor /= Void
		do
			if not attached a_class.creators as l_creators then
				if not a_class.is_deferred and a_class.is_preparsed then
					a_class.process (a_system_processor.feature_flattener)
					Result := has_seed (a_class.current_system.default_create_seed)
				end
			else
				Result := l_creators.has_feature_name (name)
			end
		end

	is_static: BOOLEAN
			-- Can feature be used as a static feature (i.e. in a call of the form {A}.f)?
		do
			Result := has_static_mark
		end

	has_static_mark: BOOLEAN
			-- Has feature been explicitly marked as static?
		do
			Result := has_class_postcondition_recursive
		end

	is_transient_attribute: BOOLEAN
			-- Is feature a transient attribute
			-- (i.e. not taken into account by Storable)?
		do
			-- Result := False
		end

	is_stable_attribute: BOOLEAN
			-- Is feature a stable attribute
			-- (i.e. cannot be set to Void in void-safe mode)?
		do
			-- Result := False
		end

	is_infixable: BOOLEAN
			-- Can current feature have a name of
			-- the form binary 'alias "..."'?
		do
			-- Result := False
		ensure
			definition: not is_dotnet implies Result = (type /= Void and (attached arguments as l_arguments and then l_arguments.count = 1))
		end

	is_prefixable: BOOLEAN
			-- Can current feature have a name of
			-- the form unary 'alias "..."'?
		do
			-- Result := False
		ensure
			definition: not is_dotnet implies Result = (type /= Void and (not attached arguments as l_arguments or else l_arguments.count = 0))
		end

	is_bracketable: BOOLEAN
			-- Can current feature have a name of
			-- the form 'alias "[]"'?
		do
			-- Result := False
		ensure
			definition: Result = (type /= Void and (attached arguments as l_arguments and then l_arguments.count > 0))
		end

	is_parenthesisable: BOOLEAN
			-- Can current feature have a name of
			-- the form 'alias "()"'?
		do
			Result := attached arguments as l_arguments and then l_arguments.count > 0
		ensure
			definition: Result = (attached arguments as l_arguments and then l_arguments.count > 0)
		end

	is_precondition_free: BOOLEAN
			-- Does the combined preconditions has value 'True'?
			-- The combined preconditions take into account the
			-- preconditions inherited from precursors.
		local
			i, nb: INTEGER
			l_other_precursor: ET_FEATURE
		do
			if attached first_precursor as l_first_precursor then
				if attached preconditions as l_preconditions and then l_preconditions.are_all_true then
					Result := True
				elseif l_first_precursor.is_precondition_free then
					Result := True
				elseif attached other_precursors as l_other_precursors then
					from
						i := 1
						nb := l_other_precursors.count
					until
						i > nb
					loop
						l_other_precursor := l_other_precursors.item (i)
						if l_other_precursor.is_precondition_free then
							Result := True
								 -- Jump out of the loop
							i := nb
						end
						i := i + 1
					end
				end
			elseif not attached preconditions as l_preconditions then
				Result := True
			elseif l_preconditions.is_empty then
				Result := True
			elseif l_preconditions.are_all_true then
				Result := True
			end
		end

	are_preconditions_instance_free_recursive: BOOLEAN
			-- Are all precondition expressions, if any, instance-free (i.e. not dependent
			-- on 'Current' or its attributes)?
			-- Take into account inherited preconditions recursively.
			-- Note that we do not consider unqualified calls and Precursors as
			-- instance-free because it's not always possible syntactically
			-- to determine whether the feature being called is a class feature
			-- or not.
		local
			i, nb: INTEGER
			l_other_precursor: ET_FEATURE
		do
			Result := True
			if attached preconditions as l_preconditions and then not l_preconditions.is_instance_free then
				Result := False
			elseif attached first_precursor as l_first_precursor then
				if not l_first_precursor.are_preconditions_instance_free_recursive then
					Result := False
				elseif attached other_precursors as l_other_precursors then
					from
						i := 1
						nb := l_other_precursors.count
					until
						i > nb
					loop
						l_other_precursor := l_other_precursors.item (i)
						if not l_other_precursor.are_preconditions_instance_free_recursive then
							Result := False
								 -- Jump out of the loop
							i := nb
						end
						i := i + 1
					end
				end
			end
		end

	are_postconditions_instance_free_recursive: BOOLEAN
			-- Are all postcondition expressions, if any, instance-free (i.e. not dependent
			-- on 'Current' or its attributes)?
			-- Take into account inherited preconditions recursively.
			-- Note that we do not consider unqualified calls and Precursors as
			-- instance-free because it's not always possible syntactically
			-- to determine whether the feature being called is a class feature
			-- or not.
		local
			i, nb: INTEGER
			l_other_precursor: ET_FEATURE
		do
			Result := True
			if attached postconditions as l_postconditions and then not l_postconditions.is_instance_free then
				Result := False
			elseif attached first_precursor as l_first_precursor then
				if not l_first_precursor.are_postconditions_instance_free_recursive then
					Result := False
				elseif attached other_precursors as l_other_precursors then
					from
						i := 1
						nb := l_other_precursors.count
					until
						i > nb
					loop
						l_other_precursor := l_other_precursors.item (i)
						if not l_other_precursor.are_postconditions_instance_free_recursive then
							Result := False
								 -- Jump out of the loop
							i := nb
						end
						i := i + 1
					end
				end
			end
		end

	has_class_postcondition_recursive: BOOLEAN
			-- Is one of the postconditions a 'class' assertion?
			-- Take into account inherited postconditions recursively.
		local
			i, nb: INTEGER
			l_other_precursor: ET_FEATURE
		do
			if attached postconditions as l_postconditions and then l_postconditions.has_class_assertion then
				Result := True
			elseif attached first_precursor as l_first_precursor then
				if l_first_precursor.has_class_postcondition_recursive then
					Result := True
				elseif attached other_precursors as l_other_precursors then
					from
						i := 1
						nb := l_other_precursors.count
					until
						i > nb
					loop
						l_other_precursor := l_other_precursors.item (i)
						if l_other_precursor.has_class_postcondition_recursive then
							Result := True
								 -- Jump out of the loop
							i := nb
						end
						i := i + 1
					end
				end
			end
		end

	is_flattened_immediate: BOOLEAN = True
			-- Is current feature immediate?
			--
			-- Note that this feature only make sense when flattening the features.
			-- Otherwise, features that are declared or redeclared in a class
			-- are available in ET_CLASS.queries and ET_CLASS.procedures from
			-- range 1 to `declared_count', and (non-redeclared) inherited features
			-- from range `declared_count' + 1 to `count'.

	is_redeclaration (a_class: ET_CLASS): BOOLEAN
			-- Assuming that the current feature has been declared in `a_class'
			-- (i.e. it appears in range 1 to 'declared_count' in 'a_class.queries'
			-- or 'a_class.procedures'), is current feature the redeclaration
			-- of a feature from a parent class of `a_class'?
			--
			-- Note that features that are declared or redeclared in a class
			-- are available in ET_CLASS.queries and ET_CLASS.procedures from
			-- range 1 to 'declared_count', and (non-redeclared) inherited features
			-- from range 'declared_count' + 1 to `count'.
		require
			a_class_not_void: a_class /= Void
			declared_in_class: a_class.has_declared_feature (Current)
		do
			Result := (first_precursor /= Void)
		end

	is_join (a_class: ET_CLASS): BOOLEAN
			-- Assuming that the current feature has been inherited without being
			-- redefined (i.e. it appears in range 'declared_count' + 1 to 'count'
			-- in 'a_class.queries' or 'a_class.procedures'), is current feature the
			-- result of a join of two or more features from the parents of `a_class'?
			--
			-- Note that features that are declared or redeclared in a class
			-- are available in ET_CLASS.queries and ET_CLASS.procedures from
			-- range 1 to 'declared_count', and (non-redeclared) inherited features
			-- from range 'declared_count' + 1 to `count'.
			--
			-- Note this may give wrong results when the current feature has been
			-- inherited from an ancestor of `a_class' without being adapted
			-- (e.g. no renaming, no join, no redeclaration, ...) and it was the
			-- result of a join in that ancestor. We will get True in that case
			-- despite the fact that there is no join in `a_class'.
		require
			a_class_not_void: a_class /= Void
			inherited_in_class: a_class.has_inherited_feature (Current)
		do
			if first_precursor /= Void then
				if implementation_feature /= Current then
					Result := attached other_precursors as l_other_precursors and then not l_other_precursors.is_empty
				end
			end
		end

	is_feature: BOOLEAN = True
			-- Is `Current' a feature?

feature -- Export status

	is_exported_to (a_client: ET_CLASS; a_system_processor: ET_SYSTEM_PROCESSOR): BOOLEAN
			-- Is current feature exported to `a_client'?
			-- (Note: Use `a_system_processor.ancestor_builder' on the classes whose ancestors
			-- need to be built in order to check for descendants.)
		require
			a_client_not_void: a_client /= Void
			a_system_processor_not_void: a_system_processor /= Void
		do
			Result := clients.has_descendant (a_client, a_system_processor)
		end

	is_directly_exported_to (a_client: ET_CLASS): BOOLEAN
			-- Does `a_client' appear in the list of clients of current feature?
			-- (This is different from `is_exported_to' where `a_client' can
			-- be a descendant of a class appearing in the list of clients.
			-- Note: The use of 'direct' in the name of this feature has not
			-- the same meaning as 'direct and indirect client' in ETL2 p.91.)
		require
			a_client_not_void: a_client /= Void
		do
			Result := clients.has_class (a_client)
		end

	is_creation_exported_to (a_client, a_class: ET_CLASS; a_system_processor: ET_SYSTEM_PROCESSOR): BOOLEAN
			-- Is current feature listed in the creation clauses of `a_class'
			-- and exported to `a_client', or is current feature the version of
			-- 'default_create' in `a_class' with `a_class' being a non-deferred
			-- class with no creation clauses?
			-- (Note: Use `a_system_processor.ancestor_builder' on the classes whose ancestors
			-- need to be built in order to check for descendants. Also use
			-- `a_system_processor.feature_flattener' on `a_class' if needed to determine
			-- whether current feature is the version of 'default_create' in `a_class'.)
		require
			a_client_not_void: a_client /= Void
			a_class_not_void: a_class /= Void
			a_system_processor_not_void: a_system_processor /= Void
		do
			if a_class.is_creation_exported_to (name, a_client, a_system_processor) then
				Result := True
			elseif a_class.creators = Void and not a_class.is_deferred and a_class.is_preparsed then
				a_class.process (a_system_processor.feature_flattener)
				Result := has_seed (a_class.current_system.default_create_seed)
			end
		end

	is_creation_directly_exported_to (a_client, a_class: ET_CLASS): BOOLEAN
			-- Is current feature listed in the creation clauses
			-- of `a_class' and directly exported to `a_client'?
			-- (This is different from `is_creation_exported_to' where `a_client'
			-- can be a descendant of a class appearing in the list of clients.
			-- Note: The use of 'direct' in the name of this feature has not
			-- the same meaning as 'direct and indirect client' in ETL2 p.91.)
		require
			a_client_not_void: a_client /= Void
			a_class_not_void: a_class /= Void
		do
			Result := a_class.is_creation_directly_exported_to (name, a_client)
		end

	add_creation_clients_to (a_clients: ET_CLIENT_LIST; a_class: ET_CLASS; a_system_processor: ET_SYSTEM_PROCESSOR)
			-- If current feature is listed in the creation clauses
			-- of `a_class', then add its creation clients to `a_clients'.
			-- If current feature the version of 'default_create' in `a_class'
			-- with `a_class' being a non-deferred class with no creation clauses,
			-- then add "ANY" to `a_clients'.
			-- (Note: Use `a_system_processor.feature_flattener' on `a_class' if needed
			-- to determine whether current feature is the version of 'default_create'
			-- in `a_class'.)
		require
			a_clients_not_void: a_clients /= Void
			a_class_not_void: a_class /= Void
			a_system_processor_not_void: a_system_processor /= Void
		do
			if not attached a_class.creators as l_creators then
				if not a_class.is_deferred and a_class.is_preparsed then
					a_class.process (a_system_processor.feature_flattener)
					if has_seed (a_class.current_system.default_create_seed) then
						a_clients.append_first (a_class.universe.any_clients)
					end
				end
			else
				l_creators.add_creation_clients_to (name, a_clients)
			end
		end

	clients: ET_CLIENT_LIST
			-- Clients to which feature is exported

	set_clients (a_clients: like clients)
			-- Set `clients' to `a_clients'.
		require
			a_clients_not_void: a_clients /= Void
		do
			clients := a_clients
		ensure
			clients_set: clients = a_clients
		end

feature -- Comparison

	same_version (other: ET_FEATURE): BOOLEAN
			-- Do current feature and `other' have the same version?
		require
			other_not_void: other /= Void
		do
			Result := (other = Current) or else (version = other.version)
		ensure
			definition: Result = (version = other.version)
		end

feature -- Setting

	set_id (an_id: INTEGER)
			-- Set `id' to `an_id'.
		require
			an_id_positive: an_id > 0
		do
			id := an_id
			if first_seed = 0 then
				set_first_seed (an_id)
			end
			if version = 0 then
				set_version (an_id)
			end
		ensure
			id_set: id = an_id
		end

	set_feature_clause (a_feature_clause: like feature_clause)
			-- Set `feature_clause' to `a_feature_clause'.
		do
			feature_clause := a_feature_clause
		ensure
			feature_clause_set: feature_clause = a_feature_clause
		end

	set_first_note (a_note: like first_note)
			-- Set `first_note' to `a_note'
		do
			first_note := a_note
		ensure
			first_note_set: first_note = a_note
		end

	set_version (a_version: INTEGER)
			-- Set `version' to `a_version'.
		require
			a_version_not_void: a_version > 0
		do
			version := a_version
		ensure
			version_set: version = a_version
		end

	set_implementation_class (a_class: like implementation_class)
			-- Set `implementation_class' to `a_class'.
		require
			a_class_not_void: a_class /= Void
		do
			implementation_class := a_class
		ensure
			implementation_class_set: implementation_class = a_class
		end

	set_implementation_feature (a_feature: like implementation_feature)
			-- Set `implementation_feature' to `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			implementation_feature := a_feature
		ensure
			implementation_feature_set: implementation_feature = a_feature
		end

	set_first_seed (a_seed: INTEGER)
			-- Set `first_seed' to `a_seed'.
		require
			a_seed_positive: a_seed > 0
		do
			first_seed := a_seed
		ensure
			first_seed_set: first_seed = a_seed
		end

	set_other_seeds (a_seeds: like other_seeds)
			-- Set `other_seeds' to `a_seeds'.
		do
			other_seeds := a_seeds
		ensure
			other_seeds_set: other_seeds = a_seeds
		end

	set_first_precursor (a_precursor: like first_precursor)
			-- Set `first_precursor' to `a_precursor'.
		do
			first_precursor := a_precursor
		ensure
			first_precursor_set: first_precursor = a_precursor
		end

	set_other_precursors (a_precursors: like other_precursors)
			-- Set `other_precursors' to `a_precursors'.
		do
			other_precursors := a_precursors
		ensure
			other_precursors_set: other_precursors = a_precursors
		end

	set_frozen_keyword (a_frozen: like frozen_keyword)
			-- Set `frozen_keyword' to `a_frozen'.
		do
			frozen_keyword := a_frozen
		ensure
			frozen_keyword_set: frozen_keyword = a_frozen
		end

	set_synonym (a_synonym: like synonym)
			-- Set `synonym' to `a_synonym'.
		do
			synonym := a_synonym
		ensure
			synonym_set: a_synonym = a_synonym
		end

	set_semicolon (a_semicolon: like semicolon)
			-- Set `semicolon' to `a_semicolon'.
		do
			semicolon := a_semicolon
		ensure
			semicolon_set: semicolon = a_semicolon
		end

	reset_preconditions
			-- Set `preconditions' to Void.
		do
		ensure
			preconditions_reset: preconditions = Void
		end

	reset_postconditions
			-- Set `postconditions' to Void.
		do
		ensure
			postconditions_reset: postconditions = Void
		end

feature -- Duplication

	new_synonym (a_name: like extended_name): like Current
			-- Synonym feature
		require
			a_name_not_void: a_name /= Void
		deferred
		ensure
			new_synonym_not_void: Result /= Void
			extended_name_set: Result.extended_name = a_name
		end

feature -- Conversion

	renamed_feature (a_name: like extended_name): like Current
			-- Renamed version of current feature
		require
			a_name_not_void: a_name /= Void
		deferred
		ensure
			renamed_feature_not_void: Result /= Void
			extended_name_set: Result.extended_name = a_name
			first_precursor_set: Result.first_precursor = first_precursor
			other_precursors_set: Result.other_precursors = other_precursors
		end

	undefined_feature (a_name: like extended_name): ET_DEFERRED_ROUTINE
			-- Undefined version of current feature
		require
			a_name_not_void: a_name /= Void
		deferred
		ensure
			undefined_feature_not_void: Result /= Void
			extended_name_set: Result.extended_name = a_name
			version_set: Result.version = Result.id
			first_precursor_set: Result.first_precursor = Current
			other_precursors_set: Result.other_precursors = Void
		end

feature -- Inheritance

	flattened_feature: ET_FEATURE
			-- Feature resulting after feature flattening
		do
			Result := Current
		ensure then
			definition: Result = Current
		end

	flattened_immediate_feature: ET_FEATURE
			-- Current feature viewed as an immediate feature
		do
			Result := Current
		end

feature -- Conversion

	as_feature: ET_FEATURE
			-- `Current' viewed as a feature
		do
			Result := Current
		end

feature -- Element change

	add_precursors (a_precursors: DS_HASH_SET [ET_FEATURE])
			-- Add (recursively) all precursors of current feature to `a_precursors'
			-- the oldest precursors first.
		require
			a_precursors_not_void: a_precursors /= Void
			no_void_precursor: not a_precursors.has_void
		local
			i, nb: INTEGER
			l_precursor: ET_FEATURE
		do
			if attached first_precursor as l_first_precursor then
				if not a_precursors.has (l_first_precursor) then
					l_first_precursor.add_precursors (a_precursors)
					a_precursors.force_last (l_first_precursor)
				end
				if attached other_precursors as l_other_precursors then
					nb := l_other_precursors.count
					from i := 1 until i > nb loop
						l_precursor := l_other_precursors.item (i)
						if not a_precursors.has (l_precursor) then
							l_precursor.add_precursors (a_precursors)
							a_precursors.force_last (l_precursor)
						end
						i := i + 1
					end
				end
			end
		ensure
			no_void_precursor: not a_precursors.has_void
		end

invariant

	extended_name_not_void: extended_name /= Void
	clients_not_void: clients /= Void
	hash_code_definition: hash_code = name.hash_code
	first_seed_positive: is_registered implies first_seed > 0
	implementation_class_not_void: implementation_class /= Void
	implementation_feature_not_void: implementation_feature /= Void
	is_flattened_immediate: is_flattened_immediate

end
