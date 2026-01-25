note

	description:

		"LSP 'textDocument/prepareTypeHierarchy' options"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_TYPE_HIERARCHY_OPTIONS

inherit

	LS_OPTIONAL_TYPE_HIERARCHY_OPTIONS

	LS_WORK_DONE_PROGRESS_OPTIONS

create

	make

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_type_hierarchy_options (Current)
		end

end
