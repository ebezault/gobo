indexing

	description:

		"Gepp tasks"

	library: "Gobo Eiffel Ant"
	copyright: "Copyright (c) 2001, Sven Ehrke and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class GEANT_GEPP_TASK

inherit

	GEANT_TASK
		rename
			make as task_make
		redefine
			command
		end

creation

	make

feature {NONE} -- Initialization

	make (a_project: GEANT_PROJECT; an_xml_element: GEANT_XML_ELEMENT) is
			-- Create a new task with information held in `an_xml_element'.
		local
			a_value: STRING
			a_bool: BOOLEAN
			define_elements: DS_ARRAYED_LIST [GEANT_XML_ELEMENT]
			define_element: GEANT_DEFINE_ELEMENT
			a_xml_subelement: GEANT_XML_ELEMENT
			a_fs_element: GEANT_FILESET_ELEMENT
			i, nb: INTEGER
		do
			!! command.make (a_project)
			task_make (command, an_xml_element)
			if has_uc_attribute (Input_filename_attribute_name) then
				a_value := uc_attribute_value (Input_filename_attribute_name).out
				if a_value.count > 0 then
					command.set_input_filename (a_value)
				end
			end
			if has_uc_attribute (Output_filename_attribute_name) then
				a_value := uc_attribute_value (Output_filename_attribute_name).out
				if a_value.count > 0 then
					command.set_output_filename (a_value)
				end
			end
			if has_uc_attribute (Lines_attribute_name) then
				a_bool := uc_boolean_value (Lines_attribute_name)
				command.set_empty_lines (a_bool)
			end
			define_elements := xml_element.children_by_name (Define_element_name)
			nb := define_elements.count
			from i := 1 until i > nb loop
				!! define_element.make (project, define_elements.item (i))
				if define_element.is_enabled and then define_element.has_name and then
					define_element.name.count > 0 then

					command.defines.force_last (define_element.name)
				end

				i := i + 1
			end

			if has_uc_attribute (To_directory_attribute_name) then
				a_value := attribute_value (To_directory_attribute_name.out)
				if a_value.count > 0 then
					command.set_to_directory (a_value.out)
				end
			end

			if has_uc_attribute (Force_attribute_name) then
				command.set_force (uc_boolean_value (Force_attribute_name))
			end

			a_xml_subelement := xml_element.child_by_name (Fileset_element_name)
			if a_xml_subelement /= Void then
				!! a_fs_element.make (project, a_xml_subelement)
				command.set_fileset (a_fs_element.fileset)
			end

		end

feature -- Access

	command: GEANT_GEPP_COMMAND
			-- Gepp commands

feature {NONE} -- Constants

	Input_filename_attribute_name: UC_STRING is
			-- Name of xml attribute for input_filename
		once
			Result := new_unicode_string ("input")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Output_filename_attribute_name: UC_STRING is
			-- Name of xml attribute for output_filename
		once
			Result := new_unicode_string ("output")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Lines_attribute_name: UC_STRING is
			-- Name of xml attribute for lines
		once
			Result := new_unicode_string ("lines")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Define_element_name: UC_STRING is
			-- Name of xml subelement for defines
		once
			Result := new_unicode_string ("define")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	To_directory_attribute_name: UC_STRING is
			-- Name of xml attribute to_directory.
		once
			Result := new_unicode_string ("to_directory")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Force_attribute_name: UC_STRING is
			-- Name of xml attribute for force
		once
			Result := new_unicode_string ("force")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Fileset_element_name: UC_STRING is
			-- Name of xml subelement for fileset
		once
			Result := new_unicode_string ("fileset")
		ensure
			element_name_not_void: Result /= Void
			element_name_not_empty: Result.count > 0
		end

end
