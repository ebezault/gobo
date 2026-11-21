note

	description:

		"Eiffel retry instructions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2026, Eric Bezault and others"
	license: "MIT License"

class ET_RETRY_INSTRUCTION

inherit

	ET_INSTRUCTION
		undefine
			first_position,
			last_position,
			break
		redefine
			has_retry_instruction
		end

	ET_KEYWORD
		rename
			make_retry as make
		redefine
			process
		end

create

	make

feature -- Status report

	has_retry_instruction: BOOLEAN = True
			-- Does a 'retry' instruction appear in current instruction or
			-- (recursively) in one of its subinstructions?

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_retry_instruction (Current)
		end

invariant

	is_retry: is_retry

end
