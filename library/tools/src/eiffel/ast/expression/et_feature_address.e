﻿note

	description:

		"Eiffel addresses of features"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2024, Eric Bezault and others"
	license: "MIT License"

class ET_FEATURE_ADDRESS

inherit

	ET_ADDRESS_EXPRESSION
		redefine
			reset
		end

create

	make

feature {NONE} -- Initialization

	make (a_name: like name)
			-- Create a new feature address.
		require
			a_name_not_void: a_name /= Void
		do
			dollar := tokens.dollar_symbol
			name := a_name
		ensure
			name_set: name = a_name
		end

feature -- Initialization

	reset
			-- Reset expression as it was just after it was last parsed.
		do
			precursor
			name.reset
		end

feature -- Access

	name: ET_FEATURE_NAME
			-- Feature name

	last_leaf: ET_AST_LEAF
			-- Last leaf node in current node
		do
			Result := name.last_leaf
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_feature_address (Current)
		end

invariant

	name_not_void: name /= Void

end
