indexing

	description:

		"XPath Element nodes"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2003, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XPATH_ELEMENT

inherit

	XM_XPATH_NODE

	XM_XPATH_COMPOSITE_NODE

	XM_XPATH_NODE_WITH_BASE_URI_OR_FROM_PARENT

	XM_XPATH_TYPED_NODE

	KL_IMPORTED_STRING_ROUTINES

feature -- Access

	node_kind: STRING is
			-- Identifies the kind of node
		do
			Result := "element"
		ensure then
			node_kind_is_element: STRING_.same_string (Result, "element")
		end

	item_type: INTEGER is
			-- Type
		do
			Result := Element_node
		end
	
feature -- Status report

	is_nilled: BOOLEAN is
			-- Is current node "nilled"? (i.e. xsi: nill="true")
		do
			Result := nilled_property
		end	

feature {NONE} -- Access

	nilled_property: BOOLEAN
			-- Nilled property from the infoset

invariant
	-- namespaces_have_unique_names: All namespace nodes must have distinct names.
	-- At most one has no name.
	-- parent_namespace_relationship: namespaces.for_all (agent (parent.is_equal (Current)))
	-- attributes_have_distinct_names: All attributes must have distinct QNames.
	-- parent_attribute_relationship: attributes.for_all (agent (parent.is_equal (Current)))

end
