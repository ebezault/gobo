note

	description:

		"Browsable names of tuple labels"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2025-2026, Eric Bezault and others"
	license: "MIT License"

class ET_BROWSABLE_TUPLE_LABEL_NAME

inherit

	ET_BROWSABLE_QUALIFIED_NAME
		rename
			make as make_browsable_qualified_name
		redefine
			name
		end

create

	make

feature {NONE} -- Initialization

	make (a_name: like name; a_target_type: like target_type; a_class: like current_class)
			-- Create a new browsable local variable name.
		require
			a_name_not_void: a_name /= Void
			a_name_is_tuple_label: a_name.is_tuple_label
			a_target_type_not_void: a_target_type /= Void
			a_class_not_void: a_class /= Void
		do
			name := a_name
			target_type := a_target_type
			current_class := a_class
		ensure
			name_set: name = a_name
			target_type_set: target_type = a_target_type
			current_class_set: current_class = a_class
		end

feature -- Access

	name: ET_IDENTIFIER
			-- AST node corresponding to the tuple label name

	labeled_parameter: detachable ET_LABELED_ACTUAL_PARAMETER
			-- Labeled actual generic parameter, if any
		local
			l_seed: INTEGER
		do
			if attached {ET_IDENTIFIER} name as l_label and then l_label.is_tuple_label then
				l_seed := l_label.seed
				if
					attached target_type.base_type (current_class).actual_parameters as l_actual_parameters and then
					l_seed >= 1 and then l_seed <= l_actual_parameters.count and then
					attached {ET_LABELED_ACTUAL_PARAMETER} l_actual_parameters.actual_parameter (l_seed) as l_labeled_parameter
				then
					Result := l_labeled_parameter
				end
			end
		end

	type_base_class: detachable ET_CLASS
			-- Base class of the type of the browsable name, if any
		do
			if attached labeled_parameter as l_labeled_parameter then
				Result := l_labeled_parameter.type.base_class (current_class)
			end
		end

feature -- Output

	append_description_to_string (a_string: STRING_8)
			-- Append `description' to `a_string'.
		do
			if attached labeled_parameter as l_labeled_parameter then
				append_tuple_label_description_to_string (l_labeled_parameter, a_string)
			end
		end

feature -- Processing

	process (a_processor: ET_BROWSABLE_NAME_PROCESSOR)
			-- Process current name.
		do
			a_processor.process_tuple_label_name (Current)
		end

invariant

	name_is_tuple_label: name.is_tuple_label

end
