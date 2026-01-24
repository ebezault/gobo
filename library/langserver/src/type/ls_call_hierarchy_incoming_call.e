note

	description:
	
		"LSP call hierarchy incoming calls"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_CALL_HIERARCHY_INCOMING_CALL

inherit

	LS_ANY

create

	make

feature {NONE} -- Initialization

	make (a_from: like from_; a_from_ranges: like from_ranges)
			-- Create a new call hierarchy incoming call.
		require
			a_from_not_void: a_from /= Void
			a_from_ranges_not_void: a_from_ranges /= Void
		do
			from_ := a_from
			from_ranges := a_from_ranges
		ensure
			from_set: from_ = a_from
			from_ranges_set: from_ranges = a_from_ranges
		end

feature -- Access

	from_: LS_CALL_HIERARCHY_ITEM
			-- The item that makes the call.

	from_ranges: LS_RANGE_LIST
			-- The ranges at which the calls appear. This is relative to the caller
			-- denoted by [`this.from`](#CallHierarchyIncomingCall.from).

feature -- Field names

	from_name: STRING_8 = "from"
	from_ranges_name: STRING_8 = "fromRanges"
			-- Field names

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_call_hierarchy_incoming_call (Current)
		end

invariant

	from_not_void: from_ /= Void
	from_ranges_not_void: from_ranges /= Void

end
