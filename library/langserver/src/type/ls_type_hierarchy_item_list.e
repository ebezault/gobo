note

	description:

		"LSP lists of type hierarchy items"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_TYPE_HIERARCHY_ITEM_LIST

inherit

	LS_LIST [LS_TYPE_HIERARCHY_ITEM]

	LS_TYPE_HIERARCHY_PREPARE_RESULT

	LS_TYPE_HIERARCHY_SUPERTYPES_RESULT

	LS_TYPE_HIERARCHY_SUBTYPES_RESULT

create

	make,
	make_with_capacity

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_type_hierarchy_item_list (Current)
		end

end
