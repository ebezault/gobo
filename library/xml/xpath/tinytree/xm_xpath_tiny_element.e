indexing

	description:

		"Tiny tree Element nodes"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_TINY_ELEMENT

inherit

	XM_XPATH_ELEMENT

	XM_XPATH_TINY_COMPOSITE_NODE

creation

	make

feature {NONE} -- Initialization

	make (doc: XM_XPATH_TINY_DOCUMENT; a_node_number: INTEGER) is
		require
			valid_document: doc /= Void
			valid_node_number: a_node_number > 1 and a_node_number <= doc.last_node_added
		do
			document := doc
			node_number := a_node_number
		ensure
			document_set: document = doc
			node_number_set: node_number = a_node_number
		end

feature {XM_XPATH_NODE} -- Access

	is_possible_child: BOOLEAN is
			-- Can this node be a child of a document or element node?
		do
			Result := True
		end
end
