note

	description:

		"Checkers of unused local variables"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"

class ET_UNUSED_LOCAL_VARIABLE_CHECKER

inherit

	ET_CLASS_PROCESSOR
		redefine
			make
		end

	ET_AST_ITERATOR
		rename
			make as make_ast_processor
		redefine
			process_class,
			process_do_function_inline_agent,
			process_do_procedure_inline_agent,
			process_local_variable_list,
			process_external_function_inline_agent,
			process_external_procedure_inline_agent,
			process_once_function_inline_agent,
			process_once_procedure_inline_agent
		end

create

	make

feature {NONE} -- Initialization

	make (a_system_processor: like system_processor)
			-- Create a new local variable checker.
		do
			precursor (a_system_processor)
			current_class := tokens.unknown_class
			current_feature := Void
		end

feature -- Basic operations

	report_unused_local_variables (a_class: ET_CLASS)
			-- Report warning for unused local variables in `a_class`.
		require
			a_class_not_void: a_class /= Void
		do
			a_class.process (Current)
		end

feature {ET_AST_NODE} -- Processing

	process_class (a_class: ET_CLASS)
			-- Process `a_class'.
		local
			l_old_current_class: like current_class
			l_old_current_feature: like current_feature
			l_queries: ET_QUERY_LIST
			l_query: ET_QUERY
			l_procedures: ET_PROCEDURE_LIST
			l_procedure: ET_PROCEDURE
			i, nb: INTEGER
		do
			l_old_current_feature := current_feature
			l_old_current_class := current_class
			current_class := a_class
			l_queries := a_class.queries
			l_procedures := a_class.procedures
			nb := l_queries.declared_count
			from i := 1 until i > nb loop
				l_query := l_queries.item (i)
				current_feature := l_query
				l_query.process (Current)
					-- Next query.
				from
				until
					l_query = Void or else l_query.synonym = Void
				loop
					i := i + 1
					if i <= nb then
						l_query := l_queries.item (i)
					else
						l_query := Void
					end
				end
				i := i + 1
			end
			nb := l_procedures.declared_count
			from i := 1 until i > nb loop
				l_procedure := l_procedures.item (i)
				current_feature := l_procedure
				l_procedure.process (Current)
					-- Next procedure.
				from
				until
					l_procedure = Void or else l_procedure.synonym = Void
				loop
					i := i + 1
					if i <= nb then
						l_procedure := l_procedures.item (i)
					else
						l_procedure := Void
					end
				end
				i := i + 1
			end
			current_feature := Void
			if attached a_class.invariants as l_invariants then
				l_invariants.process (Current)
			end
			current_class := l_old_current_class
			current_feature := l_old_current_feature
		end

	process_do_function_inline_agent (a_expression: ET_DO_FUNCTION_INLINE_AGENT)
			-- Process `a_expression'.
		local
			l_old_agent: like current_inline_agent
		do
			l_old_agent := current_inline_agent
			current_inline_agent := a_expression
			precursor (a_expression)
			current_inline_agent := l_old_agent
		end

	process_do_procedure_inline_agent (a_expression: ET_DO_PROCEDURE_INLINE_AGENT)
			-- Process `a_expression'.
		local
			l_old_agent: like current_inline_agent
		do
			l_old_agent := current_inline_agent
			current_inline_agent := a_expression
			precursor (a_expression)
			current_inline_agent := l_old_agent
		end

	process_external_function_inline_agent (a_expression: ET_EXTERNAL_FUNCTION_INLINE_AGENT)
			-- Process `a_expression'.
		local
			l_old_agent: like current_inline_agent
		do
			l_old_agent := current_inline_agent
			current_inline_agent := a_expression
			precursor (a_expression)
			current_inline_agent := l_old_agent
		end

	process_external_procedure_inline_agent (a_expression: ET_EXTERNAL_PROCEDURE_INLINE_AGENT)
			-- Process `a_expression'.
		local
			l_old_agent: like current_inline_agent
		do
			l_old_agent := current_inline_agent
			current_inline_agent := a_expression
			precursor (a_expression)
			current_inline_agent := l_old_agent
		end

	process_local_variable_list (a_list: ET_LOCAL_VARIABLE_LIST)
			-- Process `a_list'.
		local
			i, nb: INTEGER
			l_local_variable: ET_LOCAL_VARIABLE
		do
			nb := a_list.count
			from i := 1 until i > nb loop
				l_local_variable := a_list.item (i).local_variable
				if not l_local_variable.is_used then
					if not attached current_inline_agent as l_inline_agent then
						if attached current_feature as l_feature then
							error_handler.report_gwulv0a_warning (current_class, l_local_variable, l_feature)
						end
					elseif attached current_feature as l_feature then
						error_handler.report_gwulv0b_warning (current_class, l_local_variable, l_feature, l_inline_agent)
					else
						error_handler.report_gwulv0c_warning (current_class, l_local_variable, l_inline_agent)
					end
				end
				i := i + 1
			end
		end

	process_once_function_inline_agent (a_expression: ET_ONCE_FUNCTION_INLINE_AGENT)
			-- Process `a_expression'.
		local
			l_old_agent: like current_inline_agent
		do
			l_old_agent := current_inline_agent
			current_inline_agent := a_expression
			precursor (a_expression)
			current_inline_agent := l_old_agent
		end

	process_once_procedure_inline_agent (a_expression: ET_ONCE_PROCEDURE_INLINE_AGENT)
			-- Process `a_expression'.
		local
			l_old_agent: like current_inline_agent
		do
			l_old_agent := current_inline_agent
			current_inline_agent := a_expression
			precursor (a_expression)
			current_inline_agent := l_old_agent
		end

feature {NONE} -- Implementation

	current_feature: detachable ET_FEATURE
			-- Feature being processed

	current_inline_agent: detachable ET_INLINE_AGENT
			-- Inline agent being processed

end
