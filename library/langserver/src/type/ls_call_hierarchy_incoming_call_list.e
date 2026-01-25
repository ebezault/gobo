note

	description:

		"LSP lists of call hierarchy incoming calls"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_CALL_HIERARCHY_INCOMING_CALL_LIST

inherit

	LS_LIST [LS_CALL_HIERARCHY_INCOMING_CALL]

	LS_CALL_HIERARCHY_INCOMING_CALLS_RESULT

create

	make,
	make_with_capacity

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_call_hierarchy_incoming_call_list (Current)
		end

end
