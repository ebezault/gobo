note

	description:

		"LSP 'typeHierarchy/supertypes' parameters"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

deferred class LS_TYPE_HIERARCHY_SUPERTYPES_PARAMS

inherit

	LS_WORK_DONE_PROGRESS_PARAMS

	LS_PARTIAL_RESULT_PARAMS

feature -- Access

	item: LS_TYPE_HIERARCHY_ITEM
			-- Type hierarchy item.

feature -- Field names

	item_name: STRING_8 = "item"
			-- Field names

invariant

	item_not_void: item /= Void

end
