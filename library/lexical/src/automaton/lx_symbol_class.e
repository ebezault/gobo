note

	description:

		"Classes of symbols"

	storable_version: "20190721"
	library: "Gobo Eiffel Lexical Library"
	copyright: "Copyright (c) 1999-2019, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class LX_SYMBOL_CLASS

inherit

	HASHABLE
		redefine
			is_equal,
			copy
		end

create

	make,
	make_unicode

feature {NONE} -- Initialization

	make (a_min, a_max: INTEGER)
			-- Create an empty symbol class.
		require
			a_min_large_enough: a_min >= 0
			a_max_large_enough: a_max >= a_min
		do
			is_empty := True
			lower := a_min
			upper := a_max
		ensure
			lower_set: lower = a_min
			upper_set: upper = a_max
			is_empty: is_empty
			not_negated: not is_negated
			not_unicode: not is_unicode
		end

	make_unicode (a_min, a_max: INTEGER)
			-- Create an empty Unicode symbol class.
		require
			a_min_large_enough: a_min >= 0
			a_max_large_enough: a_max >= a_min
		do
			make (a_min, a_max)
			is_unicode := True
		ensure
			lower_set: lower = a_min
			upper_set: upper = a_max
			is_empty: is_empty
			not_negated: not is_negated
			is_unicode: is_unicode
		end

feature -- Access

	lower: INTEGER
			-- Smallest symbol allowed

	upper: INTEGER
			-- Largest symbol allowed

	hash_code: INTEGER
			-- Hash code value
		local
			l_code: NATURAL_64
			l_chunk_index: INTEGER
			l_chunk_upper: INTEGER
			i: INTEGER
		do
			l_code := first_set + second_set + third_set + fourth_set
			if upper >= 256 and then attached other_sets as l_other_sets then
				from
					l_chunk_index := 0
					l_chunk_upper := chunk_count - 2
				until
					l_chunk_index > l_chunk_upper or else
						(attached l_other_sets.item (l_chunk_index) as l_chunk and then
							l_chunk.count > 0 and then
								not (l_chunk.filled_with (0, 0, chunk_size - 1) or
									l_chunk.filled_with (1, 0, chunk_size - 1)))
				loop
					l_chunk_index := l_chunk_index + 1
				end
				if l_chunk_index <= l_chunk_upper and then attached l_other_sets.item (l_chunk_index) as l_chunk then
					from
						i := 0
					until
						i >= chunk_size
					loop
						l_code := l_code + l_chunk.item (i)
						i := i + 1
					end
				end
			end
			Result := (l_code & 0x0000FFFF).to_integer_32 + ((l_code & 0xFFFF0000) |>> 32).to_integer_32
			if Result < 0 then
				Result := -(Result + 1)
			end
		end

feature -- Status report

	is_unicode: BOOLEAN
			-- Does the current symbol class contains Unicode charatcters?

	is_empty: BOOLEAN
			-- Is symbol class empty?
			-- Do not take into account negated status.

	is_256_full: BOOLEAN
			-- Does symbol class contain the 256 first symbols (from 0 to 255)?
			-- Do not take into account negated status.
		do
			Result := first_set = 0xFFFFFFFF and second_set = 0xFFFFFFFF and third_set = 0xFFFFFFFF and fourth_set = 0xFFFFFFFF
		end

	is_negated: BOOLEAN
			-- Is character set negated?

	has (a_symbol: INTEGER): BOOLEAN
			-- Is `a_symbol' included in symbol class?
			-- Take into account the negated status.
		require
			a_symbol_valid: a_symbol >= lower and a_symbol <= upper
			valid_unicode: is_unicode implies {UC_UNICODE_ROUTINES}.valid_non_surrogate_code (a_symbol)
		do
			Result := added (a_symbol) /= is_negated
		ensure
			definition: Result = (added (a_symbol) /= is_negated)
		end

	added (a_symbol: INTEGER): BOOLEAN
			-- Has `a_symbol' been added to the symbol class?
			-- Do not take into account the negated status.
		require
			a_symbol_valid: a_symbol >= lower and a_symbol <= upper
			valid_unicode: is_unicode implies {UC_UNICODE_ROUTINES}.valid_non_surrogate_code (a_symbol)
		local
			l_index_in_chunk: INTEGER
			l_chunk: like chunk
		do
			if is_empty then
				Result := False
			elseif a_symbol < 64 then
				Result := first_set & masks.item (a_symbol) /= 0
			elseif a_symbol < 128 then
				Result := second_set & masks.item (a_symbol \\ 64) /= 0
			elseif a_symbol < 192 then
				Result := third_set & masks.item (a_symbol \\ 64) /= 0
			elseif a_symbol < 256 then
				Result := fourth_set & masks.item (a_symbol \\ 64) /= 0
			else
				l_chunk := chunk (a_symbol)
				if l_chunk = Void then
					Result := False
				elseif l_chunk.count = 0 then
						-- Empty chunks are considered full of ones.
					Result := True
				else
					l_index_in_chunk := index_in_chunk (a_symbol)
					Result := l_chunk [l_index_in_chunk] & masks.item (a_symbol \\ 64) /= 0
				end
			end
		end

	same_symbol_class (a_other: LX_SYMBOL_CLASS): BOOLEAN
			-- Are `a_other' and `Current' considered to be the same symbol class?
		require
			a_other_not_void: a_other /= Void
		local
			l_chunk_upper: INTEGER
			l_chunk_index: INTEGER
			l_chunk: like chunk
			l_other_chunk: like chunk
		do
			Result := True
			if is_negated /= a_other.is_negated then
				Result := False
			elseif is_unicode /= a_other.is_unicode then
				Result := False
			elseif lower /= a_other.lower then
				Result := False
			elseif upper /= a_other.upper then
				Result := False
			elseif is_empty then
				Result := a_other.is_empty
			elseif a_other.is_empty then
				Result := False
			elseif first_set /= a_other.first_set then
				Result := False
			elseif second_set /= a_other.second_set then
				Result := False
			elseif third_set /= a_other.third_set then
				Result := False
			elseif fourth_set /= a_other.fourth_set then
				Result := False
			elseif upper >= 256 then
				if attached other_sets as l_current_other_sets then
					if attached a_other.other_sets as l_other_other_sets then
						from
							l_chunk_index := 0
							l_chunk_upper := chunk_count - 1
						until
							not Result or l_chunk_index > l_chunk_upper
						loop
							l_chunk := l_current_other_sets.item (l_chunk_index)
							l_other_chunk := l_other_other_sets.item (l_chunk_index)
							if l_chunk = Void then
								if l_other_chunk /= Void then
									Result := l_other_chunk.count > 0 and then l_other_chunk.filled_with (0, 0, chunk_size - 1)
								end
							elseif l_chunk.count = 0 then
								Result := l_other_chunk /= Void and then (l_other_chunk.count = 0 or else l_other_chunk.filled_with (1, 0, chunk_size - 1))
							elseif l_other_chunk = Void then
								Result := l_chunk.filled_with (0, 0, chunk_size - 1)
							elseif l_other_chunk.count = 0 then
								Result := l_chunk.filled_with (1, 0, chunk_size - 1)
							else
								Result := l_chunk.same_items (l_other_chunk, 0, 0, chunk_size)
							end
							l_chunk_index := l_chunk_index + 1
						end
					else
						from
							l_chunk_index := 0
							l_chunk_upper := chunk_count - 1
						until
							not Result or l_chunk_index > l_chunk_upper
						loop
							l_chunk := l_current_other_sets.item (l_chunk_index)
							if l_chunk /= Void then
								Result := l_chunk.count > 0 and then l_chunk.filled_with (0, 0, chunk_size - 1)
							end
							l_chunk_index := l_chunk_index + 1
						end
					end
				elseif attached a_other.other_sets as l_other_other_sets then
					from
						l_chunk_index := 0
						l_chunk_upper := chunk_count - 1
					until
						not Result or l_chunk_index > l_chunk_upper
					loop
						l_other_chunk := l_other_other_sets.item (l_chunk_index)
						if l_other_chunk /= Void then
							Result := l_other_chunk.count > 0 and then l_other_chunk.filled_with (0, 0, chunk_size - 1)
						end
						l_chunk_index := l_chunk_index + 1
					end
				else
					Result := True
				end
			end
		end

	is_equal (other: like Current): BOOLEAN
			-- Are `a_other' and `Current' considered to be the same symbol class?
		do
			Result := same_symbol_class (other)
		end

feature -- Status setting

	set_negated (b: BOOLEAN)
			-- Set `is_negated' to `b'.
		do
			is_negated := b
		ensure
			negated_set: is_negated = b
		end

feature -- Element Change

	add_symbol (a_symbol: INTEGER)
			-- Add `a_symbol' to symbol class.
			-- Do not take into account the negated status.
		require
			a_symbol_valid: a_symbol >= lower and a_symbol <= upper
			valid_unicode: is_unicode implies {UC_UNICODE_ROUTINES}.valid_non_surrogate_code (a_symbol)
		local
			l_index_in_chunk: INTEGER
			l_chunk: like chunk
		do
			if a_symbol < 64 then
				first_set := first_set | masks.item (a_symbol)
			elseif a_symbol < 128 then
				second_set := second_set | masks.item (a_symbol \\ 64)
			elseif a_symbol < 192 then
				third_set := third_set | masks.item (a_symbol \\ 64)
			elseif a_symbol < 256 then
				fourth_set := fourth_set | masks.item (a_symbol \\ 64)
			else
				l_chunk := attached_chunk (a_symbol)
				if l_chunk.count /= 0 then
						-- Empty chunks are considered full of ones.
					l_index_in_chunk := index_in_chunk (a_symbol)
					l_chunk [l_index_in_chunk] := l_chunk [l_index_in_chunk] | masks.item (a_symbol \\ 64)
				end
			end
			is_empty := False
		ensure
			not_empty: not is_empty
			added: added (a_symbol)
		end

	add_symbol_class (other: LX_SYMBOL_CLASS)
			-- Add symbols of `other' to current symbol class.
			-- Take into account negated status of `Current' and `other'.
		require
			other_not_void: other /= Void
			same_unicode: is_unicode = other.is_unicode
			same_lower: lower = other.lower
			same_upper: upper = other.upper
		local
			l_chunk_upper: INTEGER
			l_chunk_index: INTEGER
			l_current_chunk: like chunk
			l_other_chunk: like chunk
			l_current_other_sets: like other_sets
			l_index_in_chunk: INTEGER
			l_negated, l_other_negated: BOOLEAN
			l_is_empty: BOOLEAN
		do
			l_negated := is_negated
			l_other_negated := other.is_negated
			if not l_negated and l_other_negated then
				is_negated := True
			end
			if l_negated then
				if l_other_negated then
					first_set := first_set & other.first_set
					second_set := second_set & other.second_set
					third_set := third_set & other.third_set
					fourth_set := fourth_set & other.fourth_set
				else
					first_set := first_set & other.first_set.bit_not
					second_set := second_set & other.second_set.bit_not
					third_set := third_set & other.third_set.bit_not
					fourth_set := fourth_set & other.fourth_set.bit_not
				end
			else
				if l_other_negated then
					first_set := first_set.bit_not & other.first_set
					second_set := second_set.bit_not & other.second_set
					third_set := third_set.bit_not & other.third_set
					fourth_set := fourth_set.bit_not & other.fourth_set
				else
					first_set := first_set | other.first_set
					second_set := second_set | other.second_set
					third_set := third_set | other.third_set
					fourth_set := fourth_set | other.fourth_set
				end
			end
			l_is_empty := True
			if not is_empty and not other.is_empty then
				l_is_empty := first_set = 0 and second_set = 0 and third_set = 0 and fourth_set = 0
			end
			l_current_other_sets := other_sets
			if upper < 256 then
				-- Done.
			elseif l_current_other_sets = Void then
				if not l_negated and attached other.other_sets as l_other_other_sets then
					from
						l_chunk_upper := chunk_count - 1
					until
						l_chunk_index > l_chunk_upper
					loop
						if attached l_other_other_sets.item (l_chunk_index) as l_chunk then
							if l_current_other_sets = Void then
								l_current_other_sets := attached_other_sets
							end
							if l_chunk.count = 0 then
									-- Chunk considered full of ones.
								l_current_other_sets.put (chunk_of_ones, l_chunk_index)
								l_is_empty := False
							else
								l_current_other_sets.put (l_chunk.twin, l_chunk_index)
								if l_is_empty then
									l_is_empty := l_chunk.filled_with (0, 0, chunk_size - 1)
								end
							end
						end
						l_chunk_index := l_chunk_index + 1
					end
				end
			elseif not attached other.other_sets as l_other_other_sets then
				if l_other_negated then
					l_current_other_sets.fill_with (Void, 0, chunk_count - 1)
				else
					if l_is_empty then
						from
							l_chunk_upper := chunk_count - 1
						until
							not l_is_empty or l_chunk_index > l_chunk_upper
						loop
							if attached l_current_other_sets.item (l_chunk_index) as l_chunk then
								if l_chunk.count = 0 then
										-- Chunk considered full of ones.
									l_is_empty := False
								else
									l_is_empty := l_chunk.filled_with (0, 0, chunk_size - 1)
								end
							end
							l_chunk_index := l_chunk_index + 1
						end
					end
				end
			else
				from
					l_chunk_upper := chunk_count - 1
				until
					l_chunk_index > l_chunk_upper
				loop
					l_current_chunk := l_current_other_sets.item (l_chunk_index)
					l_other_chunk := l_other_other_sets.item (l_chunk_index)
					if l_current_chunk = Void then
						if not l_negated and l_other_chunk /= Void then
							if l_other_chunk.count = 0 then
									-- Chunk considered full of ones.
								l_current_other_sets.put (chunk_of_ones, l_chunk_index)
								l_is_empty := False
							else
								l_current_other_sets.put (l_other_chunk.twin, l_chunk_index)
								if l_is_empty then
									l_is_empty := l_other_chunk.filled_with (0, 0, chunk_size - 1)
								end
							end
						end
					elseif l_other_chunk = Void then
						if l_other_negated then
							l_current_chunk.fill_with (0, 0, chunk_size - 1)
						else
							if l_is_empty then
								if l_current_chunk.count = 0 then
										-- Chunk considered full of ones.
									l_is_empty := False
								else
									l_is_empty := l_current_chunk.filled_with (0, 0, chunk_size - 1)
								end
							end
						end
					elseif l_current_chunk.count = 0 then
							-- Chunk considered full of ones.
						if l_negated then
							if l_other_negated then
								if l_other_chunk.count > 0 then
									l_current_other_sets.put (l_other_chunk.twin, l_chunk_index)
									if l_is_empty then
										l_is_empty := l_other_chunk.filled_with (0, 0, chunk_size - 1)
									end
								else
									l_is_empty := False
								end
							else
								if l_other_chunk.count = 0 then
										-- Chunk considered full of ones.
									l_current_other_sets.put (Void, l_chunk_index)
								else
									l_current_chunk := l_other_chunk.twin
									l_current_other_sets.put (l_current_chunk, l_chunk_index)
									from
										l_index_in_chunk := 0
									until
										l_index_in_chunk >= chunk_size
									loop
										l_current_chunk [l_index_in_chunk] := l_current_chunk [l_index_in_chunk].bit_not
										l_index_in_chunk := l_index_in_chunk + 1
									end
									if l_is_empty then
										l_is_empty := l_current_chunk.filled_with (0, 0, chunk_size - 1)
									end
								end
							end
						else
							if l_other_negated then
								l_current_other_sets.put (Void, l_chunk_index)
							else
								l_is_empty := False
							end
						end
					elseif l_other_chunk.count = 0 then
							-- Chunk considered full of ones.
						if l_negated then
							if l_other_negated then
								if l_is_empty then
									l_is_empty := l_current_chunk.filled_with (0, 0, chunk_size - 1)
								end
							else
								l_current_other_sets.put (Void, l_chunk_index)
							end
						else
							if l_other_negated then
								from
									l_index_in_chunk := 0
								until
									l_index_in_chunk >= chunk_size
								loop
									l_current_chunk [l_index_in_chunk] := l_current_chunk [l_index_in_chunk].bit_not
									l_index_in_chunk := l_index_in_chunk + 1
								end
								if l_is_empty then
									l_is_empty := l_current_chunk.filled_with (0, 0, chunk_size - 1)
								end
							else
								l_current_other_sets.put (chunk_of_ones, l_chunk_index)
								l_is_empty := False
							end
						end
					else
						from
							l_index_in_chunk := 0
						until
							l_index_in_chunk >= chunk_size
						loop
							if l_negated then
								if l_other_negated then
									l_current_chunk [l_index_in_chunk] := l_current_chunk [l_index_in_chunk] & l_other_chunk [l_index_in_chunk]
								else
									l_current_chunk [l_index_in_chunk] := l_current_chunk [l_index_in_chunk] & l_other_chunk [l_index_in_chunk].bit_not
								end
							else
								if l_other_negated then
									l_current_chunk [l_index_in_chunk] := l_current_chunk [l_index_in_chunk].bit_not & l_other_chunk [l_index_in_chunk]
								else
									l_current_chunk [l_index_in_chunk] := l_current_chunk [l_index_in_chunk] | l_other_chunk [l_index_in_chunk]
								end
							end
							if l_is_empty then
								l_is_empty := l_current_chunk [l_index_in_chunk] = 0
							end
							l_index_in_chunk := l_index_in_chunk + 1
						end
					end
					l_chunk_index := l_chunk_index + 1
				end
			end
			if not is_empty and not other.is_empty then
				is_empty := l_is_empty
			end
		end

	remove_symbol_class (other: LX_SYMBOL_CLASS)
			-- Remove symbols of `other' from current symbol class.
			-- Take into account negated status of `Current' and `other'.
		require
			other_not_void: other /= Void
			same_unicode: is_unicode = other.is_unicode
			same_lower: lower = other.lower
			same_upper: upper = other.upper
		do
			is_negated := not is_negated
			add_symbol_class (other)
			is_negated := not is_negated
		end

feature -- Removal

	wipe_out
			-- Remove all symbols.
		do
			first_set := 0
			second_set := 0
			third_set := 0
			fourth_set := 0
			if attached other_sets as l_other_sets then
				l_other_sets.fill_with (Void, 0, l_other_sets.upper)
			end
			is_empty := True
			is_negated := False
		ensure
			is_empty: is_empty
			not_negated: not is_negated
		end

feature -- Convertion

	convert_to_equivalence (classes: LX_EQUIVALENCE_CLASSES)
			-- Convert symbol class to class made of its
			-- symbols' equivalence classes.
		require
			classes_not_void: classes /= Void
			classes_built: classes.built
			valid_symbols: classes.valid_symbol_class (Current)
		local
			l_symbol, i, nb: INTEGER
			l_chunk_index: INTEGER
			l_index_in_chunk: INTEGER
			l_old_unicode: BOOLEAN
			l_old_upper: INTEGER
			l_old_first_set: NATURAL_64
			l_old_second_set: NATURAL_64
			l_old_third_set: NATURAL_64
			l_old_fourth_set: NATURAL_64
			l_old_set: NATURAL_64
			l_old_added: BOOLEAN
			l_chunk: like chunk
			l_done: BOOLEAN
			l_new_chunk_upper: INTEGER
		do
			l_old_unicode := is_unicode
			l_old_upper := upper
			l_old_first_set := first_set
			l_old_second_set := second_set
			l_old_third_set := third_set
			l_old_fourth_set := fourth_set
			first_set := 0
			second_set := 0
			third_set := 0
			fourth_set := 0
			is_empty := True
			is_unicode := False
			upper := classes.new_upper
			from
				l_symbol := lower
				nb := l_old_upper.min (255)
			until
				l_symbol > nb
			loop
				if l_symbol < 64 then
					l_old_added := l_old_first_set & masks.item (l_symbol) /= 0
				elseif l_symbol < 128 then
					l_old_added := l_old_second_set & masks.item (l_symbol \\ 64) /= 0
				elseif l_symbol < 192 then
					l_old_added := l_old_third_set & masks.item (l_symbol \\ 64) /= 0
				else
					l_old_added := l_old_fourth_set & masks.item (l_symbol \\ 64) /= 0
				end
				if l_old_added and then classes.is_representative (l_symbol) then
					add_symbol (classes.equivalence_class (l_symbol))
				end
				l_symbol := l_symbol + 1
			end
			if attached other_sets as l_other_sets then
				l_new_chunk_upper := chunk_count - 1
				from
					l_symbol := 256
					l_chunk_index := 0
				until
					l_symbol > l_old_upper
				loop
					l_chunk := l_other_sets.item (l_chunk_index)
					if l_chunk_index > l_new_chunk_upper then
							-- Remove unused chunks.
						l_other_sets.put (Void, l_chunk_index)
					end
					if l_chunk = Void then
						l_symbol := l_symbol + symbols_per_chunk
					elseif l_chunk.count = 0 then
							-- It is considered as full of ones.
						l_other_sets.put (Void, l_chunk_index)
						from
							nb := l_old_upper.min (l_symbol + symbols_per_chunk)
						until
							l_symbol > nb
						loop
							if classes.is_representative (l_symbol) then
								add_symbol (classes.equivalence_class (l_symbol))
							end
							l_symbol := l_symbol + 1
						end
					else
						from
							nb := l_old_upper.min (l_symbol + symbols_per_chunk)
							l_index_in_chunk := -1
							i := 65
						until
							l_symbol > nb
						loop
							if i > 64 then
								from
									l_done := False
								until
									l_symbol > nb or l_done
								loop
									l_done := True
									from
										l_index_in_chunk := l_index_in_chunk + 1
									until
										l_symbol > nb or else l_chunk [l_index_in_chunk] /= 0
									loop
										l_index_in_chunk := l_index_in_chunk + 1
										l_symbol := l_symbol + 64
										l_done := False
									end
									if l_symbol <= nb and then l_chunk [l_index_in_chunk] = 0xFFFFFFFF then
										l_chunk [l_index_in_chunk] := 0
										from
											i := 1
										until
											l_symbol > nb or i > 64
										loop
											if classes.is_representative (l_symbol) then
												add_symbol (classes.equivalence_class (l_symbol))
											end
											l_symbol := l_symbol + 1
											i := i + 1
										end
										l_index_in_chunk := l_index_in_chunk + 1
										l_done := False
									end
									i := 1
								end
								if l_symbol <= nb then
									l_old_set := l_chunk [l_index_in_chunk]
									l_chunk [l_index_in_chunk] := 0
								end
							end
							if l_symbol <= nb then
								l_old_added := l_old_set & masks.item (l_symbol \\ 64) /= 0
								if l_old_added and then classes.is_representative (l_symbol) then
									add_symbol (classes.equivalence_class (l_symbol))
								end
								l_symbol := l_symbol + 1
								i := i + 1
							end
						end
					end
					if l_old_unicode and then not {UC_UNICODE_ROUTINES}.valid_non_surrogate_code (l_symbol) then
						if l_symbol <= l_old_upper then
							l_symbol := {UC_UNICODE_CONSTANTS}.maximum_unicode_surrogate_code + 1
						end
					end
					l_chunk_index := l_chunk_index + 1
				end
					-- Remove unused chunks.
				from
					nb := l_other_sets.count - 1
				until
					l_chunk_index > nb
				loop
					l_other_sets.put (Void, l_chunk_index)
					l_chunk_index := l_chunk_index + 1
				end
			end
		end

feature -- Duplication

	copy (other: like Current)
			-- Copy `other' symbol class to `Current'.
		local
			l_chunk_count: INTEGER
			i, l_chunk_upper: INTEGER
			l_other_sets: like other_sets
		do
			standard_copy (other)
			if attached other_sets as l_other_other_sets then
				l_chunk_count := chunk_count
				create l_other_sets.make_filled (Void, l_chunk_count)
				other_sets := l_other_sets
				from
					i := 0
					l_chunk_upper := l_chunk_count - 1
				until
					i > l_chunk_upper
				loop
					if attached l_other_other_sets.item (i) as l_chunk then
						if l_chunk.count = 0 then
							l_other_sets.put (chunk_of_ones, i)
						else
							l_other_sets.put (l_chunk.twin, i)
						end
					end
					i := i + 1
				end
			end
		end

feature {LX_SYMBOL_CLASS} -- Implementation

	first_set: NATURAL_64
			-- First set of bits

	second_set: NATURAL_64
			-- Second set of bits

	third_set: NATURAL_64
			-- Third set of bits

	fourth_set: NATURAL_64
			-- Fourth set of bits

	other_sets: detachable SPECIAL [detachable SPECIAL [NATURAL_64]]
			-- Other sets of bits.
			-- Chunks of 172*64 bits.
			-- The first chunk is just before the first surrogate in Unicode mode.
			-- The second chunk is just after the last surrogate in Unicode mode.
			-- The last chunk may be smaller.
			-- 100 chunks needed to support Unicode.

	masks: SPECIAL [NATURAL_64]
			-- Bit masks
		local
			i: INTEGER
			v: NATURAL_64
		once
			create Result.make_filled (0, 64)
			from
				v := 1
				Result.put (v, 0)
				i := 1
			until
				i = 64
			loop
				v := v |<< 1
				Result.put (v, i)
				i := i + 1
			end
		ensure
			masks_not_void: Result /= Void
			count_64: Result.count = 64
		end

	attached_other_sets: attached like other_sets
			-- Attached version of `other_sets'.
			-- Create it if needed.
		local
			l_other_sets: like other_sets
		do
			l_other_sets := other_sets
			if l_other_sets = Void then
				create l_other_sets.make_filled (Void, chunk_count)
				other_sets := l_other_sets
			end
			Result := l_other_sets
		ensure
			attached_other_sets_not_void: Result /= Void
			definition: Result = other_sets
		end

	chunk_count: INTEGER
			-- Number of chunks needed to store up to `upper' symbols
		do
			if upper < 256 then
				Result := 0
			elseif is_unicode and then upper > 57343 then
					-- Last surrogate: 57343
					-- Number of surrogates: 2,048
				Result := (upper - 2_048 - 256) // symbols_per_chunk + 1
			else
				Result := (upper - 256) // symbols_per_chunk + 1
			end
		ensure
			chunk_count_not_negative: Result > 0
		end

	chunk (a_symbol: INTEGER): detachable SPECIAL [NATURAL_64]
			-- Chunk in `other_sets' associated with `a_symbol'.
			-- Void if not created yet.
		require
			a_symbol_valid: a_symbol >= lower and a_symbol <= upper
			valid_unicode: is_unicode implies {UC_UNICODE_ROUTINES}.valid_non_surrogate_code (a_symbol)
			a_symbol_in_other_sets: a_symbol >= 256
		local
			l_chunk_index: INTEGER
		do
			if attached other_sets as l_other_sets then
				if is_unicode and then a_symbol > 57343 then
						-- Last surrogate: 57343
						-- First surrogate: 55296
						-- Number of chunks before the first surrogate: (55295 - 256) // 64 // chunk_size + 1 = 5
					l_chunk_index := (a_symbol - 57344) // symbols_per_chunk + 5
				else
					l_chunk_index := (a_symbol - 256) // symbols_per_chunk
				end
				Result := l_other_sets.item (l_chunk_index)
			end
		end

	attached_chunk (a_symbol: INTEGER): attached like chunk
			-- Chunk in `other_sets' associated with `a_symbol'.
			-- Create it if needed.
		require
			a_symbol_valid: a_symbol >= lower and a_symbol <= upper
			valid_unicode: is_unicode implies {UC_UNICODE_ROUTINES}.valid_non_surrogate_code (a_symbol)
			a_symbol_in_other_sets: a_symbol >= 256
		local
			l_chunk_index: INTEGER
			l_chunk: like chunk
			l_other_sets: like other_sets
		do
			if is_unicode and then a_symbol > 57343 then
					-- Last surrogate: 57343
					-- First surrogate: 55296
					-- Number of chunks before the first surrogate: (55295 - 256) // 64 // chunk_size + 1 = 5
				l_chunk_index := (a_symbol - 57344) // symbols_per_chunk + 5
			else
				l_chunk_index := (a_symbol - 256) // symbols_per_chunk
			end
			l_other_sets := attached_other_sets
			l_chunk := l_other_sets.item (l_chunk_index)
			if l_chunk = Void then
				create l_chunk.make_filled (0, chunk_size)
				l_other_sets.put (l_chunk, l_chunk_index)
			end
			Result := l_chunk
		ensure
			attached_chunk_not_void: Result /= Void
			definition: Result = chunk (a_symbol)
		end

	index_in_chunk (a_symbol: INTEGER): INTEGER
			-- Index of `a_symbol' in its associated chunk
		require
			a_symbol_valid: a_symbol >= lower and a_symbol <= upper
			valid_unicode: is_unicode implies {UC_UNICODE_ROUTINES}.valid_non_surrogate_code (a_symbol)
			a_symbol_in_other_sets: a_symbol >= 256
		do
			if is_unicode and then a_symbol > 57343 then
					-- Last surrogate: 57343
				Result := ((a_symbol - 57344) // 64) \\ chunk_size
			else
				Result := ((a_symbol - 256) // 64) \\ chunk_size
			end
		ensure
			valid_index_in_chunk: Result >= 0 and Result < chunk_size
		end

	chunk_size: INTEGER = 172
			-- Size of each chunk

	symbols_per_chunk: INTEGER = 11_008
			-- `chunk_size' * 64

	chunk_of_ones: SPECIAL [NATURAL_64]
			-- Dummy chunk which is supposed to represent
			-- a chunk full of ones.
		once
			create Result.make_empty (0)
		ensure
			chunk_of_ones_not_void: Result /= Void
		end

invariant

	lower_large_enough: lower >= 0
	upper_large_enough: upper >= lower
	chunk_count: (not is_unicode or upper <= {UC_UNICODE_CONSTANTS}.maximum_unicode_surrogate_code) implies (not attached other_sets as l_other_sets or else l_other_sets.count = ((upper - 256) // (chunk_size * 64) + 1))
	chunk_count_unicode: (is_unicode and upper > {UC_UNICODE_CONSTANTS}.maximum_unicode_surrogate_code) implies (not attached other_sets as l_other_sets or else l_other_sets.count = ((upper - ({UC_UNICODE_CONSTANTS}.maximum_unicode_surrogate_code - {UC_UNICODE_CONSTANTS}.minimum_unicode_surrogate_code + 1) - 256) // (chunk_size * 64) + 1))
	chunk_size: attached other_sets as l_other_sets implies across l_other_sets as l_chunks all attached l_chunks.item as l_chunk and then l_chunk.count /= 0 implies l_chunk.count = chunk_size end

end
