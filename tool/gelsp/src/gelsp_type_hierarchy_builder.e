note

	description:

		"Builders for lists of type hierarchy items"

	system: "Gobo Eiffel Language Server"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class GELSP_TYPE_HIERARCHY_BUILDER

inherit

	ET_BROWSABLE_NAME_TYPE_PROCESSOR

create

	make

feature {NONE} -- Initalization

	make (a_response: like response; a_message_manager: like message_manager)
			-- Create a new type hierarchy builder.
		require
			a_response_not_void: a_response /= Void
			a_message_manager_not_void: a_message_manager /= Void
		do
			response := a_response
			message_manager := a_message_manager
		ensure
			response_set: response = a_response
			message_manager_set: message_manager = a_message_manager
		end

feature -- Access

	response: LS_TYPE_HIERARCHY_PREPARE_RESPONSE
			-- List of type hierarchy items to be built

	message_manager: GELSP
			-- Message manager

feature -- Processing

	process_class (a_class: ET_CLASS; a_browsable_name: ET_BROWSABLE_NAME)
			-- Add class `a_class` to the list of hierarchy items.
		do
			if attached message_manager.type_hierarchy_item (a_class, True) as l_type_hierarchy_item then
				response.add_type_hierarchy_item (l_type_hierarchy_item)
			end
		end

	process_formal_parameter (a_formal_parameter: ET_FORMAL_PARAMETER; a_browsable_name: ET_BROWSABLE_NAME)
			-- Add formal paramater `a_formal_parameter` to the list of hierarchy items.
		do
		end

invariant

	response_not_void: response /= Void
	message_manager_not_void: message_manager /= Void

end
