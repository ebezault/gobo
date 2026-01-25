note

	description:
	
		"LSP call hierarchy outgoing calls"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_CALL_HIERARCHY_OUTGOING_CALL

inherit

	LS_ANY

create

	make

feature {NONE} -- Initialization

	make (a_to: like to; a_from_ranges: like from_ranges)
			-- Create a new call hierarchy outgoing call.
		require
			a_to_not_void: a_to /= Void
			a_from_ranges_not_void: a_from_ranges /= Void
		do
			to := a_to
			from_ranges := a_from_ranges
		ensure
			to_set: to = a_to
			from_ranges_set: from_ranges = a_from_ranges
		end

feature -- Access

	to: LS_CALL_HIERARCHY_ITEM
			-- The item that is called.

	from_ranges: LS_RANGE_LIST
			-- The range at which this item is called. This is the range relative to
			-- the caller, e.g the item passed to `callHierarchy/outgoingCalls` request.

feature -- Field names

	to_name: STRING_8 = "to"
	from_ranges_name: STRING_8 = "fromRanges"
			-- Field names

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_call_hierarchy_outgoing_call (Current)
		end

invariant

	to_not_void: to /= Void
	from_ranges_not_void: from_ranges /= Void

end
