note

	description:

		"LSP handlers for 'typeHierarchy/subtypes' requests"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_TYPE_HIERARCHY_SUBTYPES_REQUEST_HANDLER

inherit

	LS_REQUEST_HANDLER

create

	make

feature {NONE} -- Implementation

	request: LS_TYPE_HIERARCHY_SUBTYPES_REQUEST
			-- Type of request to be handled by current handler
		do
			check False then end
		end

	response_result: LS_TYPE_HIERARCHY_SUBTYPES_RESULT
			-- Type of response result to be handled by current handler
		do
			check False then end
		end

end
