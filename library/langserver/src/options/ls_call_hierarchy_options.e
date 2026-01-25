note

	description:

		"LSP 'textDocument/prepareCallHierarchy' options"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_CALL_HIERARCHY_OPTIONS

inherit

	LS_OPTIONAL_CALL_HIERARCHY_OPTIONS

	LS_WORK_DONE_PROGRESS_OPTIONS

create

	make

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_call_hierarchy_options (Current)
		end

end
