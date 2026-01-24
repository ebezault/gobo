note

	description:

		"LSP 'CallHierarchy' capabilities"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_CALL_HIERARCHY_CAPABILITIES

inherit

	LS_DYNAMIC_REGISTRATION_CAPABILITIES

create

	make

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_call_hierarchy_capabilities (Current)
		end

end
