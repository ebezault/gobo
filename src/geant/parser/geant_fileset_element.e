indexing

	description:

		"Fileset Elements"

	library: "Gobo Eiffel Ant"
	copyright: "Copyright (c) 2001, Sven Ehrke and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class GEANT_FILESET_ELEMENT

inherit

	GEANT_ELEMENT
		redefine
			make
		end

creation

	make

feature {NONE} -- Initialization

	make (a_project: GEANT_PROJECT; a_xml_element: GEANT_XML_ELEMENT) is
			-- Create new fileset element with information held in `a_xml_element'.
			-- Create `fileset' using parameter `a_convert_to_filesystem'.
		local
			a_value: STRING
			a_xml_subelement: GEANT_XML_ELEMENT
			a_map_element: GEANT_MAP_ELEMENT
		do
			precursor (a_project, a_xml_element)
			!! fileset.make (project)

			if has_uc_attribute (Directory_attribute_name) then
				a_value := uc_attribute_value (Directory_attribute_name).out
				if a_value.count > 0 then
					fileset.set_directory_name (a_value)
				end
			end

			if has_uc_attribute (Include_attribute_name) then
				a_value := uc_attribute_value (Include_attribute_name).out
				if a_value.count > 0 then
					fileset.set_include_wc_string (a_value)
				end
			end

			if has_uc_attribute (Exclude_attribute_name) then
				a_value := uc_attribute_value (Exclude_attribute_name).out
				if a_value.count > 0 then
					fileset.set_exclude_wc_string (a_value)
				end
			end

			if has_uc_attribute (Force_attribute_name) then
				fileset.set_force (uc_boolean_value (Force_attribute_name))
			end

			if has_uc_attribute (Concat_attribute_name) then
				fileset.set_concat (uc_boolean_value (Concat_attribute_name))
			end

			a_xml_subelement := xml_element.child_by_name (Map_element_name)
			if a_xml_subelement /= Void then
				!! a_map_element.make (project, a_xml_subelement)
				fileset.set_map (a_map_element.map)
			end

		end

feature -- Access

	fileset: GEANT_FILESET
		-- Fileset executing definitions of current fileset element

feature {NONE} -- Constants

	Directory_attribute_name: UC_STRING is
			-- Name of xml attribute for directory
		once
			Result := new_unicode_string ("directory")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Include_attribute_name: UC_STRING is
			-- Name of xml attribute for include
		once
			Result := new_unicode_string ("include")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Exclude_attribute_name: UC_STRING is
			-- Name of xml attribute for exclude
		once
			Result := new_unicode_string ("exclude")
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

	Concat_attribute_name: UC_STRING is
			-- Name of xml attribute for concat
		once
			Result := new_unicode_string ("concat")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Map_element_name: UC_STRING is
			-- Name of xml subelement for map
		once
			Result := new_unicode_string ("map")
		ensure
			element_name_not_void: Result /= Void
			element_name_not_empty: Result.count > 0
		end

end
