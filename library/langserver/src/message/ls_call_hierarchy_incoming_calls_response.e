note

	description:

		"LSP reponses for 'callHierarchy/incomingCalls' requests"

	library: "Gobo Eiffel Language Server Protocol Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class LS_CALL_HIERARCHY_INCOMING_CALLS_RESPONSE

inherit

	LS_RESPONSE
		redefine
			result_
		end

create

	make,
	make_success,
	make_error

feature {NONE} -- Initialization

	make (a_id: LS_RESPONSE_ID)
			-- Create a new response.
		require
			a_id_not_void: a_id /= Void
		do
			make_success (a_id, {LS_NULL}.null)
		ensure
			id_set: id = a_id
			result_set: result_ = {LS_NULL}.null
		end

feature -- Access

	result_: detachable LS_CALL_HIERARCHY_INCOMING_CALLS_RESULT
			-- The result of a request.

feature -- Setting

	set_null_result
			-- Set `result_` to 'null'.
		do
			error := Void
			result_ := {LS_NULL}.null
		end

	set_result (a_result: LS_CALL_HIERARCHY_INCOMING_CALLS_RESULT)
			-- Set `result_` to `a_result`.
		require
			a_result_not_void: a_result /= Void
		do
			error := Void
			result_ := a_result
		ensure
			result_set: result_ = a_result
		end

	add_call_hierarchy_incoming_call (a_call_hierarchy_incoming_call: LS_CALL_HIERARCHY_INCOMING_CALL)
			-- Add `a_call_hierarchy_incoming_call` to the result.
		require
			a_call_hierarchy_incoming_call_not_void: a_call_hierarchy_incoming_call /= Void
		local
			l_list: LS_CALL_HIERARCHY_INCOMING_CALL_LIST
		do
			error := Void
			if attached {LS_CALL_HIERARCHY_INCOMING_CALL_LIST} result_ as l_incoming_call_list then
				l_incoming_call_list.put_last (a_call_hierarchy_incoming_call)
			else
				create l_list.make_with_capacity (10)
				l_list.put_last (a_call_hierarchy_incoming_call)
				result_ := l_list
			end
		end

end
