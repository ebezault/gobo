note

	description:
	
		"LSP locations inside a resource, such as a line inside a text file"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2025-2026, Eric Bezault and others"
	license: "MIT License"

class LS_LOCATION

inherit

	LS_OPTIONAL_RANGE_LOCATION
		rename
			make as male_optional_range_location
		redefine
			range,
			process
		end

	LS_DEFINITION_RESULT

	LS_TYPE_DEFINITION_RESULT

	LS_DECLARATION_RESULT

	LS_IMPLEMENTATION_RESULT

create

	make

feature {NONE} -- Initialization

	make (a_uri: like uri; a_range: like range)
			-- Create a new location.
		require
			a_uri_not_void: a_uri /= Void
			a_range_not_void: a_range /= Void
		do
			uri := a_uri
			range := a_range
		ensure
			uri_set: uri = a_uri
			range_set: range = a_range
		end

feature -- Access

	range: LS_RANGE
			-- Position range

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_location (Current)
		end

invariant

	range_not_void: range /= Void

end
