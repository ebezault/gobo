note

	description:

		"LSP lists of ranges"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_RANGE_LIST

inherit

	LS_LIST [LS_RANGE]

create

	make,
	make_with_capacity

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_range_list (Current)
		end

end
