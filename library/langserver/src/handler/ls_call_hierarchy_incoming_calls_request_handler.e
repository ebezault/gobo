note

	description:

		"LSP handlers for 'callHierarchy/incomingCalls' requests"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_CALL_HIERARCHY_INCOMING_CALLS_REQUEST_HANDLER

inherit

	LS_REQUEST_HANDLER

create

	make

feature {NONE} -- Implementation

	request: LS_CALL_HIERARCHY_INCOMING_CALLS_REQUEST
			-- Type of request to be handled by current handler
		do
			check False then end
		end

	response_result: LS_CALL_HIERARCHY_INCOMING_CALLS_RESULT
			-- Type of response result to be handled by current handler
		do
			check False then end
		end

end
