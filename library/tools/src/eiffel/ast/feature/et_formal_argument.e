﻿note

	description:

		"Eiffel formal arguments"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2024, Eric Bezault and others"
	license: "MIT License"

class ET_FORMAL_ARGUMENT

inherit

	ET_FORMAL_ARGUMENT_ITEM

create

	make

feature {NONE} -- Initialization

	make (a_name: like name_item; a_type: like declared_type)
			-- Create a new formal argument.
		require
			a_name_not_void: a_name /= Void
			a_type_not_void: a_type /= Void
		do
			name_item := a_name
			declared_type := a_type
		ensure
			name_item_set: name_item = a_name
			declared_type_set: declared_type = a_type
		end

feature -- Initialization

	reset
			-- Reset formal argument as it was when it was last parsed.
		do
			index := 0
			attached_index := 0
			name.reset
			type.reset
		end

feature -- Access

	name: ET_IDENTIFIER
			-- Name
		do
			Result := name_item.identifier
		end

	type: ET_TYPE
			-- Type
		do
			Result := declared_type.type
		end

	name_item: ET_ARGUMENT_NAME
			-- Name (possibly followed by a comma)

	declared_type: ET_DECLARED_TYPE
			-- Declared type (type preceded by a colon)

	formal_argument: ET_FORMAL_ARGUMENT
			-- Formal argument in semicolon-separated list
		do
			Result := Current
		end

	index: INTEGER
			-- Index of formal argument in enclosing feature;
			-- Used to get dynamic information about this formal argument.

	attached_index: INTEGER
			-- Index of attached version (with a CAP, Certified Attachment Pattern)
			-- of formal argument in enclosing feature;
			-- Used to get dynamic information about this formal argument.

	position: ET_POSITION
			-- Position of first character of
			-- current node in source code
		do
			Result := name_item.position
		end

	first_leaf: ET_AST_LEAF
			-- First leaf node in current node
		do
			Result := name_item.first_leaf
		end

	last_leaf: ET_AST_LEAF
			-- Last leaf node in current node
		do
			Result := declared_type.last_leaf
		end

feature -- Status report

	is_used: BOOLEAN
			-- Is current formal argument used?

feature -- Setting

	set_declared_type (a_type: like declared_type)
			-- Set `declared_type' to `a_type'.
		require
			a_type_not_void: a_type /= Void
		do
			declared_type := a_type
		ensure
			declared_type_set: declared_type = a_type
		end

	set_index (i: INTEGER)
			-- Set `index' to `i'.
		require
			i_not_negative: i >= 0
		do
			index := i
		ensure
			index_set: index = i
		end

	set_attached_index (i: INTEGER)
			-- Set `attached_index' to `i'.
		require
			i_not_negative: i >= 0
		do
			attached_index := i
		ensure
			attached_index_set: attached_index = i
		end

feature -- Status setting

	set_used (b: BOOLEAN)
			-- Set `is_used' to `b'.
		do
			is_used := b
		ensure
			used_set: is_used = b
		end

feature -- Duplication

	cloned_argument: like Current
			-- Cloned formal argument;
			-- Do not recursively clone the type
		do
			create Result.make (name_item, declared_type)
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_formal_argument (Current)
		end

invariant

	name_item_not_void: name_item /= Void
	declared_type_not_void: declared_type /= Void

end
