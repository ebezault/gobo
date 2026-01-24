note

	description:

		"Finders of features called by a given feature"

	system: "Gobo Eiffel Language Server"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class GELSP_FEATURE_CALLEE_FINDER

inherit

	ET_FEATURE_CALLEE_FINDER
		rename
			make as make_callee_finder
		redefine
			find_callees,
			report_callee
		end

	UC_SHARED_STRING_COMPARATOR
		export {NONE} all end

create

	make

feature {NONE} -- Initalization

	make (a_response: like response; a_message_manager: like message_manager; a_system_processor: like system_processor)
			-- Create a new feature callee finder.
		require
			a_response_not_void: a_response /= Void
			a_message_manager_not_void: a_message_manager /= Void
		do
			response := a_response
			message_manager := a_message_manager
			create call_hierarchy_outgoing_calls.make (100)
			make_callee_finder (a_system_processor)
		ensure
			response_set: response = a_response
			message_manager_set: message_manager = a_message_manager
			system_processor_set: system_processor = a_system_processor
		end

feature -- Access

	response: LS_CALL_HIERARCHY_OUTGOING_CALLS_RESPONSE
			-- List of call hierarchy outgoing calls to be built

	message_manager: GELSP
			-- Message manager

feature -- Basic operations

	find_callees (a_caller_closure: ET_STANDALONE_CLOSURE)
			-- Find features called by `a_caller_closure'.
		local
			l_keys: DS_ARRAYED_LIST [STRING_8]
			l_sorter: DS_QUICK_SORTER [STRING_8]
			i, nb: INTEGER
		do
			precursor (a_caller_closure)
			create l_keys.make_from_linear (call_hierarchy_outgoing_calls.keys)
			create l_sorter.make (string_comparator)
			l_keys.sort (l_sorter)
			nb := l_keys.count
			from i := 1 until i > nb loop
				if attached call_hierarchy_outgoing_calls.value (l_keys.item (i)) as l_outgoing_call then
					response.add_call_hierarchy_outgoing_call (l_outgoing_call)
				end
				i := i + 1
			end
			call_hierarchy_outgoing_calls.wipe_out
		end

	report_callee (a_call_name: ET_CALL_NAME; a_callee_class: ET_CLASS)
			-- Report that feature `a_call_name' from `a_callee_class'
			-- is called in a closure from `current_class'.
		local
			l_seed: INTEGER
			l_range: LS_RANGE
			l_detail: LS_STRING
			l_ranges: LS_RANGE_LIST
			l_key: STRING_8
		do
			l_seed := a_call_name.seed
			if l_seed /= 0 and then attached a_callee_class.seeded_feature (l_seed) as l_callee_feature then
				l_key := a_callee_class.upper_name + "." + l_callee_feature.lower_name + "." + a_callee_class.id.out
				if attached call_hierarchy_outgoing_calls.value (l_key) as l_outgoing_call then
					l_range := message_manager.range (a_call_name, current_class)
					l_ranges := l_outgoing_call.from_ranges
					l_ranges.put_last (l_range)
					create l_detail.make_from_utf8 ("(*" + l_ranges.count.out + " from " + a_callee_class.upper_name + ")")
					l_outgoing_call.to.set_detail (l_detail)
				elseif attached message_manager.call_hierarchy_outgoing_call (a_call_name, l_callee_feature, a_callee_class, current_class) as l_outgoing_call then
					call_hierarchy_outgoing_calls.force_last (l_outgoing_call, l_key)
				end
			end
		end

feature {NONE} -- Implementation

	call_hierarchy_outgoing_calls: DS_HASH_TABLE [LS_CALL_HIERARCHY_OUTGOING_CALL, STRING_8]
			-- Callees already fouund

invariant

	response_not_void: response /= Void
	message_manager_not_void: message_manager /= Void
	call_hierarchy_outgoing_calls_not_void: call_hierarchy_outgoing_calls /= Void
	no_void_call_hierarchy_outgoing_call: not call_hierarchy_outgoing_calls.has_void_item
	no_void_call_hierarchy_outgoing_calls_key: not call_hierarchy_outgoing_calls.has_void

end
