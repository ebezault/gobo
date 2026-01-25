note

	description:
	
		"LSP type hierarchy items"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_TYPE_HIERARCHY_ITEM

inherit

	LS_ANY

create

	make

feature {NONE} -- Initialization

	make (a_name: like name; a_kind: like kind; a_tags: like tags; a_detail: like detail;
		a_uri: like uri; a_range: like range; a_selection_range: like selection_range;
		a_data: like data)
			-- Create a new type hierarchy item.
		require
			a_name_not_void: a_name /= Void
			a_kind_not_void: a_kind /= Void
			a_uri_not_void: a_uri /= Void
			a_range_not_void: a_range /= Void
			a_selection_range_not_void: a_selection_range /= Void
		do
			name := a_name
			kind := a_kind
			tags := a_tags
			detail := a_detail
			uri := a_uri
			range := a_range
			selection_range := a_selection_range
			data := a_data
		ensure
			name_set: name = a_name
			kind_set: kind = a_kind
			tags_set: tags = a_tags
			detail_set: detail = a_detail
			uri_set: uri = a_uri
			range_set: range = a_range
			selection_range_set: selection_range = a_selection_range
			data_set: data = a_data
		end

feature -- Access

	name: LS_STRING
			-- The name of this item.

	kind: LS_SYMBOL_KIND
			-- The kind of this item.

	tags: detachable LS_SYMBOL_TAG_LIST
			-- Tags for this item.

	detail: detachable LS_STRING
			-- More detail for this item, e.g. the signature of a function.

	uri: LS_DOCUMENT_URI
			-- The resource identifier of this item.

	range: LS_RANGE
			-- The range enclosing this symbol not including leading/trailing whitespace
			-- but everything else, e.g. comments and code.

	selection_range: LS_RANGE
			-- The range that should be selected and revealed when this symbol is being
			-- picked, e.g. the name of a function. Must be contained by the
			-- [`range`](#TypeHierarchyItem.range).

	data: detachable LS_ANY
			-- A data entry field that is preserved between a type hierarchy prepare and
			-- supertypes or subtypes requests. It could also be used to identify the
			-- type hierarchy in the server, helping improve the performance on
			-- resolving supertypes and subtypes.

feature -- Field names

	name_name: STRING_8 = "name"
	kind_name: STRING_8 = "kind"
	tags_name: STRING_8 = "tags"
	detail_name: STRING_8 = "detail"
	uri_name: STRING_8 = "uri"
	range_name: STRING_8 = "range"
	selection_range_name: STRING_8 = "selectionRange"
	data_name: STRING_8 = "data"
			-- Field names

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_type_hierarchy_item (Current)
		end

invariant

	name_not_void: name /= Void
	kind_not_void: kind /= Void
	uri_not_void: uri /= Void
	range_not_void: range /= Void
	selection_range_not_void: selection_range /= Void

end
