note

	description:

		"LSP 'typeHierarchy/supertypes' requests"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_TYPE_HIERARCHY_SUPERTYPES_REQUEST

inherit

	LS_REQUEST

	LS_TYPE_HIERARCHY_SUPERTYPES_PARAMS

create

	make

feature {NONE} -- Initialization

	make (a_id: like id; a_item: like item; a_work_done_token: like work_done_token; a_partial_result_token: like partial_result_token)
			-- Create a new 'typeHierarchy/supertypes' request.
		require
			a_id_not_void: a_id /= Void
			a_item_not_void: a_item /= Void
		do
			id := a_id
			item := a_item
			work_done_token := a_work_done_token
			partial_result_token := a_partial_result_token
		ensure
			id_set: id = a_id
			item_set: item = a_item
			work_done_token_set: work_done_token = a_work_done_token
			partial_result_token_set: partial_result_token = a_partial_result_token
		end

feature -- Access

	method: LS_STRING
			-- Method to be invoked
		once
			Result := "typeHierarchy/supertypes"
		ensure then
			instance_free: class
		end

	handler (a_manager: LS_MESSAGE_MANAGER): LS_TYPE_HIERARCHY_SUPERTYPES_REQUEST_HANDLER
			-- Message handler for current request
		do
			Result := a_manager.type_hierarchy_supertypes_request_handler
		ensure then
			instance_free: class
		end

feature -- Processing

	process (a_processor: LS_PROCESSOR)
			-- Process current value.
		do
			a_processor.process_type_hierarchy_supertypes_request (Current)
		end

end
