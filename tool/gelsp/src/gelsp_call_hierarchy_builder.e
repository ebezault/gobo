note

	description:

		"Builders for lists of call hierarchy items"

	system: "Gobo Eiffel Language Server"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class GELSP_CALL_HIERARCHY_BUILDER

inherit

	ET_BROWSABLE_NAME_NULL_PROCESSOR
		rename
			make as make_browsable_name_processor
		redefine
			process_class_name,
			process_precursor_name,
			process_qualified_call_name,
			process_unqualified_call_name
		end

create

	make

feature {NONE} -- Initalization

	make (a_response: like response; a_message_manager: like message_manager)
			-- Create a new call hierarchy builder.
		require
			a_response_not_void: a_response /= Void
			a_message_manager_not_void: a_message_manager /= Void
		do
			response := a_response
			message_manager := a_message_manager
			make_browsable_name_processor
		ensure
			response_set: response = a_response
			message_manager_set: message_manager = a_message_manager
		end

feature -- Access

	response: LS_CALL_HIERARCHY_PREPARE_RESPONSE
			-- List of call hierarchy items to be built

	message_manager: GELSP
			-- Message manager

feature -- Basic operations

	report_caller (a_call_name: ET_CALL_NAME; a_caller: ET_STANDALONE_CLOSURE)
			-- Report that `callee_feature' from `callee_class' is called
			-- in `a_caller` from `current_class` by `a_call_name`.
		do
			if attached {ET_FEATURE} a_caller as l_feature then
				if attached message_manager.call_hierarchy_item (l_feature, l_feature.implementation_class) as l_call_hierarchy_item then
					response.add_call_hierarchy_item (l_call_hierarchy_item)
				end
			end
		end

feature {ET_BROWSABLE_NAME} -- Processing

	process_class_name (a_name: ET_BROWSABLE_CLASS_NAME)
			-- Process `a_name`.
		local
			l_class: ET_CLASS
		do
			l_class := a_name.actual_class
			if attached message_manager.client_supplier_hierarchy_item (l_class) as client_supplier_hierarchy_item then
				response.add_call_hierarchy_item (client_supplier_hierarchy_item)
			end
		end

	process_precursor_name (a_name: ET_BROWSABLE_PRECURSOR_NAME)
			-- Process `a_name`.
		local
			l_class: ET_CLASS
		do
			if attached a_name.call_feature as l_feature then
				l_class := a_name.target_type.base_class (a_name.current_class)
				if attached message_manager.call_hierarchy_item (l_feature, l_class) as l_call_hierarchy_item then
					response.add_call_hierarchy_item (l_call_hierarchy_item)
				end
			end
		end

	process_qualified_call_name (a_name: ET_BROWSABLE_QUALIFIED_CALL_NAME)
			-- Process `a_name`.
		local
			l_class: ET_CLASS
		do
			if attached a_name.call_feature as l_feature then
				l_class := a_name.target_type.base_class (a_name.current_class)
				if attached message_manager.call_hierarchy_item (l_feature, l_class) as l_call_hierarchy_item then
					response.add_call_hierarchy_item (l_call_hierarchy_item)
				end
			end
		end

	process_unqualified_call_name (a_name: ET_BROWSABLE_UNQUALIFIED_CALL_NAME)
			-- Process `a_name`.
		do
			if attached a_name.call_feature as l_feature then
				if attached message_manager.call_hierarchy_item (l_feature, a_name.current_class) as l_call_hierarchy_item then
					response.add_call_hierarchy_item (l_call_hierarchy_item)
				end
			end
		end

invariant

	response_not_void: response /= Void
	message_manager_not_void: message_manager /= Void

end
