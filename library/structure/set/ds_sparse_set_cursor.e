indexing

	description:

		"Cursors for sparse set traversals"

	library:    "Gobo Eiffel Structure Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999-2001, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date$"
	revision:   "$Revision$"

class DS_SPARSE_SET_CURSOR [G]

inherit

	DS_BILINEAR_CURSOR [G]
		redefine
			off
		end

	DS_SET_CURSOR [G]
		undefine
			off
		end

creation

	make

feature {NONE} -- Initialization

	make (a_set: like container) is
			-- Create a new cursor for `a_set'.
		require
			a_set_not_void: a_set /= Void
		do
			container := a_set
			position := Before_position
		ensure
			container_set: container = a_set
			before: before
		end

feature -- Access

	item: G is
			-- Item at cursor position
		do
			Result := container.items_item (position)
		end

	container: DS_SPARSE_SET [G]
			-- Set traversed

feature -- Status report

	after: BOOLEAN is
			-- Is there no valid position to right of cursor?
		do
			Result := position = After_position
		end

	before: BOOLEAN is
			-- Is there no valid position to left of cursor?
		do
			Result := position = Before_position
		end

	off: BOOLEAN is
			-- Is there no item at cursor position?
		do
			Result := position < 0
		end

	is_first: BOOLEAN is
			-- Is cursor on the first item?
		local
			i: INTEGER
			a_set: like container
		do
			a_set := container
			if not a_set.is_empty then
				from
					i := 1
				until
					a_set.clashes_item (i) > Free_watermark
				loop
					i := i + 1
				end
				Result := (position = i)
			end
		end

	is_last: BOOLEAN is
			-- Is cursor on the last item?
		local
			i: INTEGER
			a_set: like container
		do
			a_set := container
			if not a_set.is_empty then
				from
					i := a_set.last_position
				until
					a_set.clashes_item (i) > Free_watermark
				loop
					i := i - 1
				end
				Result := (position = i)
			end
		end

	same_position (other: like Current): BOOLEAN is
			-- Is current cursor at same position as `other'?
		do
			Result := position = other.position
		end

feature -- Cursor movement

	start is
			-- Move cursor to first position.
		local
			i, nb: INTEGER
			a_set: like container
			was_off: BOOLEAN
		do
			a_set := container
			if a_set.is_empty then
				position := After_position
			else
				was_off := off
				from
					i := 1
					nb := a_set.last_position
				until
					i > nb or else
					a_set.clashes_item (i) > Free_watermark
				loop
					i := i + 1
				end
				if i > nb then
					position := After_position
					if not was_off then
						a_set.remove_traversing_cursor (Current)
					end
				else
					position := i
					if was_off then
						a_set.add_traversing_cursor (Current)
					end
				end
			end
		end

	finish is
			-- Move cursor to last position.
		local
			i: INTEGER
			a_set: like container
			was_off: BOOLEAN
		do
			a_set := container
			if a_set.is_empty then
				position := Before_position
			else
				was_off := off
				from
					i := a_set.last_position
				until
					i < 1 or else
					a_set.clashes_item (i) > Free_watermark
				loop
					i := i - 1
				end
				if i < 1 then
					position := Before_position
					if not was_off then
						a_set.remove_traversing_cursor (Current)
					end
				else
					position := i
					if was_off then
						a_set.add_traversing_cursor (Current)
					end
				end
			end
		end

	forth is
			-- Move cursor to next position.
		local
			i, nb: INTEGER
			a_set: like container
			was_off: BOOLEAN
		do
			if position = Before_position then
				was_off := True
				i := 1
			else
				-- was_off := False
				i := position + 1
			end
			from
				a_set := container
				nb := a_set.last_position
			until
				i > nb or else
				a_set.clashes_item (i) > Free_watermark
			loop
				i := i + 1
			end
			if i > nb then
				position := After_position
				if not was_off then
					a_set.remove_traversing_cursor (Current)
				end
			else
				position := i
				if was_off then
					a_set.add_traversing_cursor (Current)
				end
			end
		end

	back is
			-- Move cursor to previous position.
		local
			i: INTEGER
			a_set: like container
			was_off: BOOLEAN
		do
			a_set := container
			if position = After_position then
				was_off := True
				i := a_set.last_position
			else
				-- was_off := False
				i := position - 1
			end
			from
			until
				i < 1 or else
				a_set.clashes_item (i) > Free_watermark
			loop
				i := i - 1
			end
			if i < 1 then
				position := Before_position
				if not was_off then
					a_set.remove_traversing_cursor (Current)
				end
			else
				position := i
				if was_off then
					a_set.add_traversing_cursor (Current)
				end
			end
		end

	search_forth (v: G) is
			-- Move to first position at or after current
			-- position where `item' and `v' are equal.
			-- (Use `equality_tester''s criterion from `container'
			-- if not void, use `=' criterion otherwise.)
			-- Move `after' if not found.
		local
			a_tester: DS_EQUALITY_TESTER [G]
		do
			a_tester := container.equality_tester
			if a_tester /= Void then
				from until
					after or else a_tester.test (item, v)
				loop
					forth
				end
			else
					-- Use `=' as comparison criterion.
				from until
					after or else item = v
				loop
					forth
				end
			end
		end

	search_back (v: G) is
			-- Move to first position at or before current
			-- position where `item' and `v' are equal.
			-- (Use `equality_tester''s criterion from `container'
			-- if not void, use `=' criterion otherwise.)
			-- Move `before' if not found.
		local
			a_tester: DS_EQUALITY_TESTER [G]
		do
			a_tester := container.equality_tester
			if a_tester /= Void then
				from until
					before or else a_tester.test (item, v)
				loop
					back
				end
			else
					-- Use `=' as comparison criterion.
				from until
					before or else item = v
				loop
					back
				end
			end
		end

	go_after is
			-- Move cursor to `after' position.
		local
			was_off: BOOLEAN
		do
			was_off := off
			position := After_position
			if not was_off then
				container.remove_traversing_cursor (Current)
			end
		end

	go_before is
			-- Move cursor to `before' position.
		local
			was_off: BOOLEAN
		do
			was_off := off
			position := Before_position
			if not was_off then
				container.remove_traversing_cursor (Current)
			end
		end

	go_to (other: like Current) is
			-- Move cursor to `other''s position.
		local
			was_off: BOOLEAN
		do
			was_off := off
			position := other.position
			if not off then
				if was_off then
					container.add_traversing_cursor (Current)
				end
			elseif not was_off then
				container.remove_traversing_cursor (Current)
			end
		end

feature {DS_SPARSE_SET, DS_SPARSE_SET_CURSOR} -- Implementation

	position: INTEGER
			-- Internal position in set

feature {DS_SPARSE_SET} -- Implementation

	set_position (p: INTEGER) is
			-- Set `position' to `p'.
		require
			valid_p: valid_position (p)
		do
			position := p
		ensure
			position_set: position = p
		end

	set_after is
			-- Set `position' to after position
		do
			position := After_position
		ensure
			after: after
		end

	valid_position (p: INTEGER): BOOLEAN is
			-- Is `p' a valid value for `position'?
		do
			Result := (p = Before_position or p = After_position) or
				(container.valid_position (p) and then container.valid_slot (p))
		ensure
			not_off: (container.valid_position (p) and then container.valid_slot (p)) implies Result
			before: (p = Before_position) implies Result
			after: (p = After_position) implies Result
			valid_slot: (Result and container.valid_position (p)) implies container.valid_slot (p)
		end

feature {NONE} -- Implementation

	Before_position: INTEGER is -1
	After_position: INTEGER is -2
			-- Special values for before and after positions

	Free_watermark: INTEGER is -1
			-- Limit between free and occupied slots in
			-- `container.clashes'

invariant

-- The following assertion are commented out because
-- some Eiffel compilers check invariants even when the
-- execution of the creation procedure is not completed.
-- (In this case, this is `container' which is not fully
-- created yet, breaking its invariant.)

--	valid_position: valid_position (position)

end -- class DS_SPARSE_SET_CURSOR
