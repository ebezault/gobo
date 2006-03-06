indexing

	description:

		"Values that have not yet been evaluated"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_MEMO_CLOSURE

inherit
	
	XM_XPATH_CLOSURE
		redefine
			make, create_iterator, same_expression, process, is_memo_closure, as_memo_closure, count,
			item_at, is_node_sequence
		end

create {XM_XPATH_EXPRESSION_FACTORY}

	make

		-- An XM_XPATH_MEMO_CLOSURE represents a value that has not yet been evaluated: the value is represented
		--  by an expression, together with saved values of all the context variables that the
		--  expression depends on. It is designed for when the value may be read more than once.

		-- The XM_XPATH_MEMO_CLOSURE maintains a reservoir containing those items in the value that have
		--  already been read. When a new iterator is requested to read the value, this iterator
		--  first examines and returns any items already placed in the reservoir by previous
		--  users of the XM_XPATH_MEMO_CLOSURE. When the reservoir is exhausted, it then uses an underlying
		--  input iterator to read further values of the underlying expression. If the value is
		--  not read to completion (for example, if the first user did exists($expr), then the
		--  input iterator is left positioned where this user abandoned it. The next user will read
		--  any values left in the reservoir by the first user, and then pick up iterating the
		--  base expression where the first user left off. Eventually, all the values of the
		--  expression will find their way into the reservoir, and future users simply iterate
		--  over the reservoir contents. Alternatively, of course, the values may be left unread.

		-- Delayed evaluation is used only for expressions with a static type that allows
		--  more than one item, so the evaluate_item routine will not normally be used, but it is
		--  supported for completeness.

		-- The expression may depend on local variables and on the context item; these values
		--  are held in the saved XM_XPATH_CONTEXT object that is kept as part of the XM_XPATH_MEMO_CLOSURE, and they
		--  will always be read from that object. The expression may also depend on global variables;
		--  these are unchanging, so they can be read from the XM_XSLT_BINDERY in the normal way. Expressions
		--  that depend on other contextual information, for example the values of position(), last(),
		--  current(), current-group(), should not be evaluated using this mechanism: they should
		--  always be evaluated eagerly. This means that the XM_XPATH_MEMO_CLOSURE does not need to keep a copy
		--  of these context variables.

feature {NONE} -- Initialization

	make (an_expression: XM_XPATH_COMPUTED_EXPRESSION; a_context: XM_XPATH_CONTEXT) is
			-- Establish invariant.
		do
			state := Unread_state
			is_node_sequence := is_node_item_type (an_expression.item_type)
			if is_node_sequence then
				create node_reservoir.make_default
			else
				create reservoir.make_default
			end
			Precursor (an_expression, a_context)
		end

	is_memo_closure: BOOLEAN is
			-- Is `Current' a memo-closure?
		do
			Result := True
		end

	as_memo_closure: XM_XPATH_MEMO_CLOSURE is
			-- `Current' seen as a closure
		do
			Result := Current
		end

feature -- Access
	
	count: INTEGER is
			-- Number of items in `Current'
		do
			if state = All_read_state then
				if is_node_sequence then
					Result := node_reservoir.count
				else
					Result := reservoir.count
				end
			else
				Result := Precursor
			end
		end

	item_at (an_index: INTEGER) :XM_XPATH_ITEM is
			-- Item at `an_index'
		local
			a_reservoir: like reservoir
		do
			if is_node_sequence then
				a_reservoir := node_reservoir
			else
				a_reservoir := reservoir
			end
			if an_index <= a_reservoir.count then
				Result := a_reservoir.item (an_index)
			elseif state = All_read_state then
				Result := Void
			elseif state = Unread_state then
				Result := Precursor (an_index)
			else

				-- We need to read some more items - this actually alters
				--  the internal state, but not the externally visible state

				from
				until
					an_index = a_reservoir.count or else state = All_read_state
				loop
					if input_iterator.is_error then
						create {XM_XPATH_INVALID_ITEM} Result.make (input_iterator.error_value)
					elseif input_iterator.before then
						input_iterator.start
					else
						input_iterator.forth
					end
					if input_iterator.is_error then
						create {XM_XPATH_INVALID_ITEM} Result.make (input_iterator.error_value)
					elseif input_iterator.after then
						state := All_read_state
					elseif input_iterator.is_node_iterator then
						check
							node_sequence: is_node_sequence
						end
						node_reservoir.force_last (input_iterator.as_node_iterator.item)
						state := Maybe_more_state
					else
						check
							not_node_sequence: not is_node_sequence
						end
						reservoir.force_last (input_iterator.item)
						state := Maybe_more_state
					end
				end
				if state = Maybe_more_state then
					Result := a_reservoir.item (an_index)
				else
					check
						out_of_range: input_iterator.is_error
						-- pre-condition for `an_index'
					end
					create {XM_XPATH_INVALID_ITEM} Result.make (input_iterator.error_value)
				end
			end
		end

feature -- Comparison

	same_expression (other: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Are `Current' and `other' the same expression?
		do
			Result := other = Current
		end

feature -- Evaluation

	create_iterator (a_context: XM_XPATH_CONTEXT) is
			-- An iterator over the values of a sequence
		local
			a_reservoir: like reservoir
		do
			last_iterator := Void
			if is_node_sequence then
				a_reservoir := node_reservoir
			else
				a_reservoir := reservoir
			end
			if a_reservoir.count > 0 then
				if input_iterator.is_error then
					last_iterator := input_iterator
				elseif input_iterator /= Void and then input_iterator.after then
					state := All_read_state
				end
			end
			if last_iterator = Void then
				inspect
					state
				when Unread_state then
					state := Busy_state
					base_expression.create_iterator (saved_xpath_context)
					input_iterator := base_expression.last_iterator
					state := Maybe_more_state
					if input_iterator.is_error then
						last_iterator := input_iterator
					elseif is_node_sequence then
						create {XM_XPATH_PROGRESSIVE_NODE_ITERATOR} last_iterator.make (node_reservoir, input_iterator.as_node_iterator, Current)
					else
						create {XM_XPATH_PROGRESSIVE_ITERATOR} last_iterator.make (reservoir, input_iterator, Current)
					end
				when Maybe_more_state then
					if input_iterator.is_error then
						last_iterator := input_iterator
					elseif  is_node_sequence then
						create {XM_XPATH_PROGRESSIVE_NODE_ITERATOR} last_iterator.make (node_reservoir, input_iterator.as_node_iterator, Current)
					else
						create {XM_XPATH_PROGRESSIVE_ITERATOR} last_iterator.make (reservoir, input_iterator, Current)
					end
				when All_read_state then
					if is_node_sequence then
						create {XM_XPATH_ARRAY_NODE_LIST_ITERATOR} last_iterator.make (node_reservoir)
					else
						create {XM_XPATH_ARRAY_LIST_ITERATOR [XM_XPATH_ITEM]} last_iterator.make (reservoir)
					end
				when Busy_state then
					create {XM_XPATH_INVALID_ITERATOR} last_iterator.make_from_string ("Attempt to access a lazily-evaluated variable while it is being evaluated",
																											 Gexslt_eiffel_type_uri, "BUSY_CLOSURE", Dynamic_error)
					check
						busy_memo_closure: False
						-- BUG
					end
				end
			end
		end

	process (a_context: XM_XPATH_CONTEXT) is
			-- Execute `Current' completely, writing results to the current `XM_XPATH_RECEIVER'.
		do
			todo ("process", False)
		end
	
feature {XM_XPATH_MEMO_CLOSURE, XM_XPATH_PROGRESSIVE_ITERATOR, XM_XPATH_PROGRESSIVE_NODE_ITERATOR} -- Restricted

	state: INTEGER
			-- Information on items read

	Unread_state: INTEGER is 1
	Maybe_more_state: INTEGER is 2
	All_read_state: INTEGER is 3
	Busy_state: INTEGER is 4
	
feature {XM_XPATH_MEMO_CLOSURE} -- Local

	is_node_sequence: BOOLEAN
			-- Do we deliver a node sequence?

	reservoir: DS_ARRAYED_LIST [XM_XPATH_ITEM]
			-- List of items already read

	node_reservoir: DS_ARRAYED_LIST [XM_XPATH_NODE]
			-- List of nodes already read

feature {XM_XPATH_PROGRESSIVE_ITERATOR, XM_XPATH_PROGRESSIVE_NODE_ITERATOR} -- restricted

	is_all_read: BOOLEAN is
			-- Is `Current' in `All_read_state'?
		do
			Result := state = All_read_state
		end

	mark_as_all_read is
			-- Set `Current' to `All_read_state'.
		require
			maybe_more: state =	Maybe_more_state
		do
			state := All_read_state
		ensure
			all_read: state = All_read_state
		end
			
invariant

	state: Unread_state <= state and state <= Busy_state
	reservoir_not_void: not is_node_sequence implies reservoir /= Void
	node_reservoir_not_void: is_node_sequence implies node_reservoir /= Void
	input_iterator: state /= Unread_state implies input_iterator /= Void
	node_iterator: is_node_sequence and then input_iterator /= Void implies input_iterator.is_node_iterator
	empty_reservoir: reservoir /= Void and then reservoir.count = 0 and then input_iterator /= Void implies input_iterator.off
	empty_node_reservoir: node_reservoir /= Void and then node_reservoir.count = 0 and then input_iterator /= Void implies input_iterator.off

end
