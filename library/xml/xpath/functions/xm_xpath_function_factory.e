indexing

	description:

		"Objects that create XPath functions"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_FUNCTION_FACTORY

inherit

	XM_XPATH_STANDARD_NAMESPACES

	XM_UNICODE_CHARACTERS_1_1

	UC_SHARED_STRING_EQUALITY_TESTER

creation

	make

feature {NONE} -- Initialization

	make is
			-- Establish invariant
		do
			create extension_function_factories.make_with_equality_testers (3, Void, string_equality_tester)
		end

feature -- Access

	is_function_available (a_uri, a_local_name: STRING; an_arity: INTEGER): BOOLEAN is
			-- Is {`a_uri'}`a_local_name' with `an_arity' an available function ?
		require
			uri_not_void: a_uri /= Void
			valid_local_name: a_local_name /= Void and then a_local_name.count > 0
			nearly_positive_arity: an_arity >= -1
		do
			if STRING_.same_string (a_uri, Xpath_functions_uri) then
				Result := is_system_function (a_local_name, an_arity)
			elseif is_reserved_namespace (a_uri) then
				Result := False
			else
				Result := is_extension_function (a_uri, a_local_name, an_arity)
			end
		end

	is_extension_function (a_uri, a_local_name: STRING; an_arity: INTEGER): BOOLEAN is
			-- Does `a_uri', `a_local_name' represent a known extension function?
			-- If `an_arity' = -1, then ignore `an_arity' (any match for `a_local_name' will do)
		require
			uri_not_reserved: a_uri /= Void and then not is_reserved_namespace (a_uri) and then a_uri.count > 0
			valid_local_name: a_local_name /= Void and then a_local_name.count > 0
			nearly_positive_arity: an_arity >= -1
		local
			an_extension_function_factory: XM_XPATH_EXTENSION_FUNCTION_FACTORY
		do
			if is_extension_function_factory_registered (a_uri) then
				an_extension_function_factory := extension_function_factories.item (a_uri)
				Result := an_extension_function_factory.has (a_local_name, an_arity)
			end
		end

	extension_function (a_uri, a_local_name: STRING; an_arity: INTEGER): XM_XPATH_FUNCTION_CALL is
			-- Function named `a_uri', `a_local_name' with `an_arity' arguments;
			-- If `an_arity' = -1, then ignore `an_arity' (any match for `a_uri', `a_local_name' will do)
		require
			uri_not_reserved: a_uri /= Void and then not is_reserved_namespace (a_uri) and then a_uri.count > 0
			valid_local_name: a_local_name /= Void and then a_local_name.count > 0
			nearly_positive_arity: an_arity >= -1
			is_extension_function: is_extension_function (a_uri, a_local_name, an_arity)
		local
			an_extension_function_factory: XM_XPATH_EXTENSION_FUNCTION_FACTORY			
		do
			an_extension_function_factory := extension_function_factories.item (a_uri)
			Result := an_extension_function_factory.function (a_local_name, an_arity)
		ensure
			extension_function_not_void: Result /= Void
		end

	is_system_function (a_function_name: STRING; an_arity: INTEGER): BOOLEAN is
			-- Is `a_function_name' sn available system function?
			-- If `an_arity' = -1, then ignore `an_arity' (any match for `a_function_name' will do)
		require
			valid_function_name: a_function_name /= Void and then is_ncname (a_function_name)
			system_function_factory_registered: is_system_function_factory_registered
			nearly_positive_arity: an_arity >= -1												
		do
			Result := system_function_factory.has (a_function_name, an_arity)
		end

	system_function (a_function_name: STRING): XM_XPATH_FUNCTION_CALL is
			-- Function named `a_function_name' in the XPath functions namespace
		require
			valid_function_name: a_function_name /= Void and then is_ncname (a_function_name)
			system_function_factory_registered: is_system_function_factory_registered
			is_system_function: is_system_function (a_function_name, -1)
		do
			Result := system_function_factory.system_function (a_function_name)
		end

feature -- Status report

	is_system_function_factory_registered: BOOLEAN
			-- Has an XM_XPATH_SYSTEM_FUNCTION_FACTORY been registered?

	is_extension_function_factory_registered (a_uri: STRING): BOOLEAN is
			-- Is `a_uri' registered against an extension function factory?
		require
			uri_not_reserved: a_uri /= Void and then not is_reserved_namespace (a_uri) and then a_uri.count > 0
		do
			Result := extension_function_factories.has (a_uri)
		end

feature -- Status setting

	register_system_function_factory (a_system_function_factory: XM_XPATH_SYSTEM_FUNCTION_FACTORY) is
			-- Register a system function factory.
		require
			factory_not_void: a_system_function_factory /= Void
		do
			system_function_factory := a_system_function_factory
			is_system_function_factory_registered := True
		ensure
			factory_registered: is_system_function_factory_registered and system_function_factory = a_system_function_factory
		end

	register_extension_function_factory (an_extension_function_factory: XM_XPATH_EXTENSION_FUNCTION_FACTORY; a_uri: STRING) is
			-- Register an extension function factory for `a_uri'.
			-- N.B. The same factory may be registered for multiple URIs
		require
			factory_not_void: an_extension_function_factory /= Void
			uri_not_reserved: a_uri /= Void and then not is_reserved_namespace (a_uri) and then a_uri.count > 0
			not_already_registered: not  is_extension_function_factory_registered(a_uri)
		do
			extension_function_factories.force (an_extension_function_factory, a_uri)
		ensure
			factory_registered: is_extension_function_factory_registered (a_uri)
			correct_factory: extension_function_factories.item (a_uri) = an_extension_function_factory
		end
	
feature {NONE} -- Implementation

	system_function_factory: XM_XPATH_SYSTEM_FUNCTION_FACTORY
			-- The registered system function factory

	extension_function_factories: DS_HASH_TABLE [XM_XPATH_EXTENSION_FUNCTION_FACTORY, STRING]
			-- registered extension function factories
	
invariant

	system_function_factory_not_void: is_system_function_factory_registered implies system_function_factory /= Void

end
