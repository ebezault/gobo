%{
indexing

	description: 

		"Full XML parser"

	implements: "XML 1.0 (Second Edition) - W3C Recommendation 6 October 2000"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XF_FULL_PARSER

inherit

	YY_PARSER_SKELETON [ANY]
		rename
			make as make_parser,
			report_error as on_error
		undefine
			on_error
		end

	XM_CALLBACKS
		export
			{NONE} all
		end

	XM_DTD_CALLBACKS
		export
			{NONE} all
		end

	XF_PARSER_TOKENS
		export
			{NONE} all
		end

	XF_PARSER_ERRORS
		export
			{NONE} all
		end

	UC_UNICODE_FACTORY
		export
			{NONE} all
		end

-- TODO:
-- character classes validation: external
-- pi: should have space after PI_TARGET?
-- getting error messages from scanner
-- check no external entity or DTD for standalone docs
-- xml declaration in external entities
-- DTD external id lacks base, public name

%}

%type <XF_PARSER_NAME> namespace_name s_tag_name s_tag e_tag attribute
%type <DS_HASH_SET[XF_PARSER_NAME]> s_tag_trail
%type <STRING> namespace_name_second nm_token doctype_name
%type <STRING> entity_value entity_value_trail
%type <STRING> att_value att_value_trail att_value_trail_item
%type <STRING> value_reference entity_value_reference
%type <STRING> comment_content comment_content_item pi_content_first pi_content_trail pi_content_item
%type <STRING> cdata_body content_text
%type <XM_DTD_EXTERNAL_ID> external_id public_id
%type <STRING> ndata_decl doctype_name_space
%type <XM_DTD_ELEMENT_CONTENT> content_spec children cp choice choice_trail seq seq_trail mixed mixed_trail
%type <CHARACTER> repetition 
%type <DS_BILINKED_LIST[XM_DTD_ATTRIBUTE_CONTENT]> attlist_decl_trail
%type <XM_DTD_ATTRIBUTE_CONTENT> att_def att_type att_tokenized_type enumerated_type default_decl
%type <DS_BILINKED_LIST[STRING]> enumeration enumeration_trail

%token <STRING> NAME 
%token <STRING> NMTOKEN
%token <STRING> EQ
%token <STRING> SPACE
%token <STRING> CHARDATA
%token <STRING> COMMENT_START COMMENT_END COMMENT_DASHDASH
%token <STRING> PI_START PI_TARGET PI_END PI_RESERVED
%token <STRING> XMLDECLARATION_START
%token <STRING> XMLDECLARATION_END
%token <STRING> XMLDECLARATION_VERSION
%token <STRING> XMLDECLARATION_STANDALONE_YES
%token <STRING> XMLDECLARATION_STANDALONE_NO
%token <STRING> XMLDECLARATION_ENCODING
%token <STRING> CDATA_START
%token <STRING> CDATA_END
%token <STRING> DOCTYPE_START
%token <STRING> DOCTYPE_END
%token <STRING> DOCTYPE_DECLARATION_START DOCTYPE_DECLARATION_END
%token <STRING> DOCTYPE_ELEMENT_EMPTY DOCTYPE_ELEMENT_ANY
%token <STRING> DOCTYPE_ELEMENT DOCTYPE_ATTLIST DOCTYPE_ENTITY DOCTYPE_NOTATION
%token <STRING> DOCTYPE_GROUP_START DOCTYPE_GROUP_END
%token <STRING> DOCTYPE_GROUP_OR DOCTYPE_GROUP_SEQ
%token <STRING> DOCTYPE_GROUP_ZEROMORE DOCTYPE_GROUP_ANY DOCTYPE_GROUP_ONEMORE
%token <STRING> DOCTYPE_PCDATA
%token <STRING> DOCTYPE_PUBLIC
%token <STRING> DOCTYPE_SYSTEM
%token <STRING> DOCTYPE_REQUIRED DOCTYPE_IMPLIED DOCTYPE_FIXED
%token <STRING> DOCTYPE_ATT_CDATA DOCTYPE_ATT_ID 
%token <STRING> DOCTYPE_ATT_IDREF DOCTYPE_ATT_IDREFS
%token <STRING> DOCTYPE_ATT_ENTITY DOCTYPE_ATT_ENTITIES 
%token <STRING> DOCTYPE_ATT_NMTOKEN DOCTYPE_ATT_NMTOKENS
%token <STRING> DOCTYPE_ATT_NOTATION
%token <STRING> DOCTYPE_PERCENT
%token <STRING> DOCTYPE_PEREFERENCE
%token <STRING> ENTITYVALUE_PEREFERENCE
%token <STRING> DOCTYPE_IGNORE DOCTYPE_INCLUDE
%token <STRING> DOCTYPE_NDATA
%token <STRING> DOCTYPE_CONDITIONAL_START
%token <STRING> DOCTYPE_CONDITIONAL_END
%token <STRING> DOCTYPE_CONDITIONAL_IGNORE
%token <STRING> VALUE_START
%token <STRING> VALUE_END
%token <STRING> TAG_START
%token <STRING> TAG_START_END
%token <STRING> TAG_END_EMPTY
%token <STRING> TAG_END
%token <STRING> TAG_NAME_FIRST
%token <STRING> TAG_NAME_ATOM
%token <STRING> TAG_NAME_COLON
%token <STRING> CONTENT_ENTITY CONTENT_CONDITIONAL_END
%token <STRING> ATTRIBUTE_ENTITY ATTRIBUTE_LT
%token <STRING> ENTITY_INVALID INPUT_INVALID

%%
-- This grammar is heavily based on the standard's EBNF productions.
-- Production names are the same as far as sensible and the productions 
-- are in the same order as in the standard text, whose section headings 
-- are included.

-- 2.1 Well formed XML documents

document: prolog element misc_maybe
	;

-- Convenience productions (out of the standard)

-- Namespace handling: to be fully compatible with XML 1.0 which allows 
-- any number of colons in names while still be ready to support namespaces,
-- namespace names (outside of DTD declarations) are handled as a list 
-- of colon-separated atoms.

namespace_name: TAG_NAME_FIRST
		{
			$$ := new_namespace_name
			$$.force_last ($1)
		}
	| TAG_NAME_COLON
		{
			$$ := new_namespace_name
			$$.force_last (shared_empty_string)
		}
	| namespace_name TAG_NAME_COLON namespace_name_second
		{ 
			$$ := $1
			$$.force_last ($3)
		}
	| namespace_name TAG_NAME_COLON
		{
			$$ := $1
			$$.force_last (shared_empty_string)
		}
	;

namespace_name_second: TAG_NAME_ATOM { $$ := $1 }
	| TAG_NAME_FIRST { $$ := $1 }
	;

nm_token: doctype_name { $$ := $1 }
	| NMTOKEN { $$ := $1 }
	;

-- within the DTD name = keywords + ordinary words
-- this is not handled within the scanner because the position 
-- of a word determines whether it is a keyword or not.

doctype_name: NAME { $$ := $1 }
	| DOCTYPE_ATT_CDATA { $$ := $1 }
	| DOCTYPE_ATT_ID { $$ := $1 }
	| DOCTYPE_ATT_IDREF { $$ := $1 }
	| DOCTYPE_ATT_IDREFS { $$ := $1 }
	| DOCTYPE_ATT_ENTITY { $$ := $1 }
	| DOCTYPE_ATT_ENTITIES { $$ := $1 }
	| DOCTYPE_ATT_NMTOKEN { $$ := $1 }
	| DOCTYPE_ATT_NMTOKENS { $$ := $1 }
	| DOCTYPE_ATT_NOTATION { $$ := $1 }
	| DOCTYPE_ELEMENT_EMPTY { $$ := $1 }
	| DOCTYPE_ELEMENT_ANY { $$ := $1 }
	| DOCTYPE_IGNORE { $$ := $1 }
	| DOCTYPE_INCLUDE { $$ := $1 }
	| DOCTYPE_NDATA { $$ := $1 }
	;

maybe_space: -- Empty
	| req_space
	;
	
req_space: space_item
	| req_space space_item
	;

space_item: SPACE
	| DOCTYPE_PEREFERENCE 
		{ 
			-- really applies only in DTD, but token cannot appear in content
			-- and test above would catch, if unintentionally.
			if not in_external_dtd then 
				force_error	(Error_doctype_peref_only_in_dtd) 
			end 
		}
	;
		
-- 2.3 Common syntactic constructs

entity_value: VALUE_START VALUE_END
		{ $$ := shared_empty_string }
	| VALUE_START entity_value_trail VALUE_END
		{ $$ := $2 }
	;

entity_value_trail: CHARDATA
		{ $$ := $1 }
	| entity_value_reference
		{ $$ := $1 }
	| entity_value_trail CHARDATA
		{ $$ := concatenate ($1, $2) }
	| entity_value_trail entity_value_reference
		{ $$ := concatenate ($1, $2) }
	;

entity_value_reference: ENTITYVALUE_PEREFERENCE
		{ $$ := entity_referenced_in_entity_value ($1) }
-- character_reference now CHARDATA
-- bypassed entity handled by scanner
	;
	
att_value: VALUE_START VALUE_END
		{ $$ := shared_empty_string }
	| VALUE_START att_value_trail VALUE_END
		{ $$ := $2 }
	;

att_value_trail: att_value_trail_item
		{ $$ := $1 }
	| att_value_trail att_value_trail_item
		{ $$ := concatenate ($1, $2) }
	;

att_value_trail_item: CHARDATA { $$ := $1 }
	| value_reference { $$ := $1 }
	| ATTRIBUTE_LT { force_error (Error_lt_not_allowed_attribute_value) }
	;
	
value_reference: ATTRIBUTE_ENTITY { $$ := shared_empty_string } -- really handled by read_token
	;

-- 2.5 Comments

comment: COMMENT_START comment_content COMMENT_END
		{ on_comment (onstring ($2)) }
	| COMMENT_START COMMENT_END
		{ on_comment (onstring (shared_empty_string)) }
	;

comment_content: comment_content_item
		{ $$ := $1 }
	| comment_content comment_content_item
		{ $$ := concatenate ($1, $2) }
	;
	
comment_content_item: CHARDATA { $$ := $1 }
	| COMMENT_DASHDASH { force_error (Error_no_dash_dash_in_comment) }
	;

-- 2.6 Processing instructions

pi: PI_START PI_TARGET req_space pi_content_first pi_content_trail PI_END
		{ on_processing_instruction (onstring ($2), onstring (concatenate ($4,$5))) }
	| PI_START PI_TARGET req_space pi_content_first PI_END
		{ on_processing_instruction (onstring ($2), onstring ($4)) }	
	| PI_START PI_TARGET maybe_space PI_END
		{ on_processing_instruction (onstring ($2), onstring (shared_empty_string)) }
	| PI_RESERVED { force_error (Error_pi_xml_reserved) }
	;

pi_content_trail: pi_content_item
		{ $$ := $1 }
	| pi_content_trail pi_content_item
		{ $$ := concatenate ($1, $2) }
	;

pi_content_item: CHARDATA { $$ := $1 }
	| PI_TARGET	{ $$ := $1 }
	| SPACE	{ $$ := $1 }
	;

pi_content_first: CHARDATA { $$ := $1 }
	| PI_TARGET	{ $$ := $1 }
	;
	
-- 2.7 CDATA section

cd_sect: CDATA_START CDATA_END
		{ on_content (onstring (shared_empty_string)) }
	| CDATA_START cdata_body CDATA_END
		{ on_content (onstring ($2)) }
	;

cdata_body: CHARDATA
		{ $$ := $1 }
	| cdata_body CHARDATA
		{ $$ := concatenate ($1, $2) }
	;

-- 2.8 Prolog and DTD

prolog: xml_decl_misc doctype_decl_misc
	;

xml_decl_misc: misc_maybe
	| xml_decl
	| xml_decl misc_trail
	;
	
doctype_decl_misc: -- Empty
	| doctype_decl
	| doctype_decl misc_trail
	;
	
misc_maybe: 
	| misc_trail
	;

misc_trail: misc
	| misc_trail misc
	;

xml_decl:XMLDECLARATION_START version_info xml_decl_opt XMLDECLARATION_END
	| XMLDECLARATION_START error { force_error (Error_xml_declaration) }
	;

xml_decl_opt: maybe_space
	| req_space sd_decl maybe_space
	| req_space encoding_decl maybe_space
	| req_space encoding_decl req_space sd_decl maybe_space
	;
	
version_info: XMLDECLARATION_VERSION
	;

misc: comment
	| pi
	| SPACE
	;

doctype_decl: doctype_decl_internal
	| doctype_decl_external doctype_decl_dtd
	;

doctype_decl_internal: DOCTYPE_START req_space doctype_name maybe_space doctype_decl_declaration DOCTYPE_END
	{ on_doctype (onstring ($3), Void, True) }
	;
	
doctype_decl_external: DOCTYPE_START req_space doctype_name req_space external_id maybe_space doctype_decl_declaration DOCTYPE_END
	 {
		on_doctype (onstring ($3), $5, False)

		debug ("xml_parser") io.put_string ("[dtd: in]") end
		in_external_dtd := True
		when_external_dtd ($5) 
	}
	;

-- External DTD
doctype_decl_dtd: DOCTYPE_DECLARATION_START text_decl doctype_decl_dtd_content DOCTYPE_DECLARATION_END
		{
			if not in_external_dtd then
				force_error (Error_misplaced_dtd_declaration)
			end
			debug ("xml_parser") io.put_string ("[dtd: out]") end
			in_external_dtd := False
		}
	;

doctype_decl_dtd_content: -- Empty
	| doctype_decl_dtd_items
	;

doctype_decl_dtd_items: doctype_decl_dtd_item
	| doctype_decl_dtd_items doctype_decl_dtd_item
	;
	
doctype_decl_dtd_item: markup_decl
	| conditional_sect
	;

-- Internal DTD	
doctype_decl_declaration: -- Empty
	| DOCTYPE_DECLARATION_START DOCTYPE_DECLARATION_END maybe_space
	| DOCTYPE_DECLARATION_START doctype_decl_declaration_content DOCTYPE_DECLARATION_END maybe_space
	;
	
doctype_decl_declaration_content: markup_decl
	| doctype_decl_declaration_content markup_decl
	;

-- DTD body
markup_decl: element_decl
	| attlist_decl
	| entity_decl
	| notation_decl
	| PI
	| comment
	| SPACE -- not in XML1.0:29?
	| DOCTYPE_PEREFERENCE
	;
	
-- 2.9 Stand-alone document declaration

sd_decl: XMLDECLARATION_STANDALONE_YES { stand_alone := True }
	| XMLDECLARATION_STANDALONE_NO { stand_alone := False }
	;

-- 3. Element

element: empty_elem_tag
	| s_tag e_tag 
		{ if not ($1).is_equal ($2) then force_error (Error_end_tag_mismatch) end }
	| s_tag content e_tag
		{ if not ($1).is_equal ($3) then force_error (Error_end_tag_mismatch) end }
	| s_tag content error { force_error (Error_element_end_tag) }
	| s_tag error { force_error (Error_element_content) }
	;


-- 3.1 Element tags

s_tag: TAG_START s_tag_name TAG_END
		{
			$$ := $2
			on_start_tag_finish
		}
	| TAG_START s_tag_name req_space s_tag_trail TAG_END
		{
			$$ := $2
			on_start_tag_finish
		}
	| TAG_START error { force_error (Error_start_tag) }
	;

empty_elem_tag: TAG_START s_tag_name TAG_END_EMPTY
		{
			on_start_tag_finish -- makes empty attributes
			on_end_tag (Void, 
					onstring ($2.ns_prefix),
					onstring ($2.local_part))
		}
	| TAG_START s_tag_name req_space s_tag_trail TAG_END_EMPTY
		{
			on_start_tag_finish
			on_end_tag (Void, 
					onstring ($2.ns_prefix), 
					onstring ($2.local_part))
		}
	;

s_tag_name: namespace_name
		{
			$$ := $1
			on_start_tag (Void,
					onstring ($1.ns_prefix),
					onstring ($1.local_part))
		}
	;
	
s_tag_trail: attribute
		{
			$$ := new_name_set
			$$.force_new ($1)
		}
	| s_tag_trail req_space attribute
		{
			$$ := $1
			if ($$).has ($3) then
				force_error (Error_attribute_duplicate)
			else
				$$.force_new ($3)
			end
		}
	;

attribute: namespace_name EQ att_value
		{
			$$ := $1
			on_attribute (Void,
					onstring ($1.ns_prefix),
					onstring ($1.local_part),
					onstring ($3))
		}
	| namespace_name error 
		{ force_error (Error_attribute) }
	;

e_tag: TAG_START_END namespace_name TAG_END
		{
			$$ := $2
			on_end_tag (Void,
					onstring ($2.ns_prefix),
					onstring ($2.local_part))
		}
	| TAG_START_END error { force_error (Error_end_tag) }
	;

content: content_item
	| content content_item
	;

content_item: content_text { on_content (onstring ($1)) }
	| cd_sect
	| element
	| pi
	| comment
	| CONTENT_CONDITIONAL_END { force_error (Error_no_cdata_end_in_content) }
	| entity_in_content
	;

entity_in_content: CONTENT_ENTITY -- no action, switched in read_token
	| XMLDECLARATION_END { force_error (Error_entity_xml_declaration) }
	;
	
content_text: CHARDATA -- includes character_reference
		{ $$ := $1 }
	| SPACE 
		{ $$ := $1 }
	;

-- 3.2 Element type declaration

element_decl: DOCTYPE_ELEMENT req_space doctype_name req_space content_spec DOCTYPE_END
	{ on_element_declaration (onstring ($3),$5) }
	| DOCTYPE_ELEMENT error { force_error (Error_doctype_element) }
	;

content_spec: DOCTYPE_ELEMENT_EMPTY maybe_space
	{ !! $$.make_empty }
	| DOCTYPE_ELEMENT_ANY maybe_space
	{ !! $$.make_any }
	| mixed maybe_space
	{ $$ := $1 }
	| children
	{ $$ := $1 }
	;

children: choice maybe_space
	{ $$ := $1 }
	| choice repetition
	{ $$ := $1; set_element_repetition ($$, $2) }
	| seq maybe_space
	{ $$ := $1 }
	| seq repetition
	{ $$ := $1; set_element_repetition ($$, $2) }
	;

cp: doctype_name_space
	{ $$ := element_name ($1) }
	| doctype_name repetition
	{ $$ := element_name ($1); set_element_repetition ($$, $2) }
	| choice maybe_space
	{ $$ := $1 }
	| choice repetition
	{ $$ := $1; set_element_repetition ($$, $2) }
	| seq maybe_space
	{ $$ := $1 }
	| seq repetition
	{ $$ := $1; set_element_repetition ($$, $2) }
	;

repetition: DOCTYPE_GROUP_ANY maybe_space
	{ $$ := '*' }
	| DOCTYPE_GROUP_ONEMORE maybe_space
	{ $$ := '+' }
	| DOCTYPE_GROUP_ZEROMORE maybe_space
	{ $$ := '?' }
	;

choice: group_start cp group_or choice_trail group_end
	{ $$ := $4; $$.items.force_first ($2) }
	;-- ensure choice.is_choice (that's why $4 is used)

choice_trail: cp
	{ !! $$.make_choice; $$.items.force_last ($1) }
	| choice_trail group_or cp
	{ $$ := $1; $$.items.force_last ($3) }
	; -- ensure choice_trail.is_choice


seq: group_start seq_trail group_end
	{ $$ := $2 }
	;

seq_trail: cp
	{ !! $$.make_sequence; $$.items.force_last ($1) }
	| seq_trail group_seq cp
	{ $$ := $1; $$.items.force_last ($3) }
	; -- ensure seq_trail.is_sequence

mixed: group_start pc_data group_end
	{ !! $$.make_mixed }
	| group_start pc_data group_end DOCTYPE_GROUP_ANY
	{ !! $$.make_mixed; $$.set_zero_or_more } 
	| group_start pc_data group_or mixed_trail group_end DOCTYPE_GROUP_ANY
	{ $$ := $4; $$.set_zero_or_more }
	; -- ensure mixed.is_content_mixed

mixed_trail: doctype_name_space
	{ !! $$.make_mixed; $$.items.force_last (element_name ($1)) }
	| mixed_trail group_or doctype_name_space
	{ $$ := $1; $$.items.force_last (element_name ($3)) }
	; -- ensure mixed_trail.is_content_mixed

-- primitives with space

doctype_name_space: DOCTYPE_NAME maybe_space
	{ $$ := $1 }
	;
	
group_start: DOCTYPE_GROUP_START maybe_space
	;
	
group_or: DOCTYPE_GROUP_OR maybe_space
	;
	
group_seq: DOCTYPE_GROUP_SEQ maybe_space
	;
	
group_end: DOCTYPE_GROUP_END
	;

pc_data: DOCTYPE_PCDATA maybe_space
	;
	
-- 3.3 Attribute list declaration

attlist_decl: DOCTYPE_ATTLIST req_space doctype_name maybe_space DOCTYPE_END
	-- empty declaration, what to do?
	| DOCTYPE_ATTLIST req_space doctype_name attlist_decl_trail maybe_space DOCTYPE_END
	{  on_attribute_declarations ($3, $4) }
	| DOCTYPE_ATTLIST error 
	{ force_error (Error_doctype_attribute) }
	;

attlist_decl_trail: att_def
	{ !! $$.make; $$.force_last ($1) }
	|  attlist_decl_trail att_def
	{ $$ := $1; $$.force_last ($2) }
	;

att_def: req_space doctype_name req_space att_type req_space default_decl
	{ $$ := $4; $$.set_name (onstring ($2)); $$.copy_default ($6) }
	| req_space doctype_name error { force_error (Error_doctype_attribute_item) }
	;

att_type: DOCTYPE_ATT_CDATA -- string_type
	{ !! $$.make; $$.set_data }
	| att_tokenized_type
	{ $$ := $1 }
	| enumerated_type
	{ $$ := $1 }
	;
	
att_tokenized_type: DOCTYPE_ATT_ID
	{ !! $$.make; $$.set_id }
	| DOCTYPE_ATT_IDREF
	{ !! $$.make; $$.set_id_ref }
	| DOCTYPE_ATT_IDREFS
	{ !! $$.make; $$.set_id_ref; $$.set_list_type }
	| DOCTYPE_ATT_ENTITY
	{ !! $$.make; $$.set_entity }
	| DOCTYPE_ATT_ENTITIES
	{ !! $$.make; $$.set_entity; $$.set_list_type }
	| DOCTYPE_ATT_NMTOKEN
	{ !! $$.make; $$.set_token }
	| DOCTYPE_ATT_NMTOKENS
	{ !! $$.make; $$.set_token; $$.set_list_type }
	;	

enumerated_type: notation_type
	{ !! $$.make; $$.set_notation }
	| enumeration
	{ !! $$.make; $$.set_enumeration }
	;

notation_type: DOCTYPE_ATT_NOTATION req_space group_start notation_type_trail DOCTYPE_GROUP_END
	;

notation_type_trail: doctype_name_space
	| notation_type_trail group_or doctype_name_space
	;

enumeration: group_start enumeration_trail group_end
	{ $$ := $2 }
	;

enumeration_trail: nm_token maybe_space
	{ !! $$.make; $$.force_last ($1) }
	| enumeration_trail group_or nm_token maybe_space
	{ $$ := $1; $$.force_last ($3) }
	;

default_decl: DOCTYPE_REQUIRED
	{ !! $$.make; $$.set_value_required }
	| DOCTYPE_IMPLIED
	{ !! $$.make; $$.set_value_implied }
	| DOCTYPE_FIXED req_space att_value
	{ !! $$.make; $$.set_value_fixed (onstring ($3)) }
	| att_value
	{ !! $$.make; $$.set_default_value (onstring($1)) }
	;

-- 3.4 Conditional section

conditional_sect: include_sect
	| ignore_sect
	| DOCTYPE_CONDITIONAL_START error { force_error (Error_doctype_conditional_section) }
	;

include_sect: include_header DOCTYPE_CONDITIONAL_END
	| include_header doctype_decl_dtd_items DOCTYPE_CONDITIONAL_END
	;

include_header: DOCTYPE_CONDITIONAL_START maybe_space DOCTYPE_INCLUDE maybe_space DOCTYPE_DECLARATION_START
	;
	
ignore_sect: ignore_header ignore_sect_content DOCTYPE_CONDITIONAL_END
	;
	
ignore_header: DOCTYPE_CONDITIONAL_START maybe_space DOCTYPE_IGNORE maybe_space DOCTYPE_DECLARATION_START
		{ scanner.push_start_condition_dtd_ignore }
	;
	
ignore_sect_content: --Empty
	| ignore_sect_items
	;
	
ignore_sect_items: ignore_sect_item
	| ignore_sect_items ignore_sect_item
	;

ignore_sect_item: CHARDATA
	| DOCTYPE_CONDITIONAL_START ignore_sect_content DOCTYPE_CONDITIONAL_END
	;
	
-- 4.1 Reference

-- reference: ENTITY is used directly depending on context
		
-- 4.2 Entity declarations

entity_decl: ge_decl 
	| pe_decl
	| DOCTYPE_ENTITY error { force_error (Error_doctype_entity) }
	;
	
ge_decl: DOCTYPE_ENTITY req_space doctype_name req_space entity_value maybe_space DOCTYPE_END
		{ -- internal entity
			when_entity_declared ($3, new_literal_entity ($5))
			on_entity_declaration (onstring ($3), False, onstring ($5), Void, Void)
		}
	| DOCTYPE_ENTITY req_space doctype_name req_space external_id maybe_space DOCTYPE_END
		{ -- external entity
			when_entity_declared ($3, new_external_entity ($5))
			on_entity_declaration (onstring ($3), False, Void, $5, Void)
		}
	| DOCTYPE_ENTITY req_space doctype_name req_space external_id ndata_decl maybe_space DOCTYPE_END
		{ -- unparsed NDATA entity
			on_entity_declaration (onstring ($3), False, Void, $5, onstring ($6))
		}
	;
	
pe_decl: DOCTYPE_ENTITY req_space DOCTYPE_PERCENT req_space doctype_name req_space entity_value maybe_space DOCTYPE_END
		{ -- internal PE entity
			when_pe_entity_declared ($5, new_literal_entity ($7))
			on_entity_declaration (onstring ($5), True, onstring ($7), Void, Void) 
		}
	| DOCTYPE_ENTITY req_space DOCTYPE_PERCENT req_space doctype_name req_space external_id maybe_space DOCTYPE_END
		{ -- external PE entity
			when_pe_entity_declared ($5, new_external_entity ($7)) 
			on_entity_declaration (onstring ($5), True, Void, $7, Void)
		}
	;
	
external_id: DOCTYPE_SYSTEM
		{ !! $$.make;  $$.set_system (onstring ($1)) }
	;

-- see problem in scanner
--external_id: DOCTYPE_SYSTEM
--		{ !! $$.make; $$.set_system (onstring ($1)) }
--	| DOCTYPE_PUBLIC DOCTYPE_SYSTEM
--		{ !! $$.make; $$.set_public (onstring ($1)); $$.set_system (onstring ($2)) }
--	;

ndata_decl: req_space DOCTYPE_NDATA req_space doctype_name -- $2 is 'NDATA'
	{ $$ := $4 }
	;

-- 4.3 Parsed entities

text_decl: -- Empty
	| XMLDECLARATION_START encoding_decl maybe_space XMLDECLARATION_END
	| XMLDECLARATION_START version_info req_space encoding_decl maybe_space XMLDECLARATION_END
	| XMLDECLARATION_START error { force_error (Error_xml_declaration) }
	;

encoding_decl: XMLDECLARATION_ENCODING
	;

-- 4.7 Notation declaration

notation_decl: DOCTYPE_NOTATION req_space doctype_name req_space external_id maybe_space DOCTYPE_END
		{ on_notation_declaration (onstring ($3), $5) }
	| DOCTYPE_NOTATION req_space doctype_name req_space public_id maybe_space DOCTYPE_END
		{ on_notation_declaration (onstring ($3), $5) }
	| DOCTYPE_NOTATION error
		{ force_error (Error_doctype_notation) }
	;

public_id: DOCTYPE_PUBLIC
		{ !! $$.make; $$.set_system (onstring ($1)) }
	;

%%
feature {NONE} -- creation

	make is
			-- Initialise.
		do
			make_scanner
			make_parser

			-- parser state
			stand_alone := False
			in_external_dtd := False
			
			-- entities
			!! entities.make_default
			!! pe_entities.make_default
		end

	-- reset?

feature {NONE} -- State

	stand_alone: BOOLEAN
			-- From XML declaration.

	entities: DS_HASH_TABLE [XF_ENTITY_DEF,STRING]
			-- Defined entites
	pe_entities: DS_HASH_TABLE [XF_ENTITY_DEF,STRING]
			-- Defined PE entities

	in_external_dtd: BOOLEAN
			-- Is the scanner in an external DTD?

feature {NONE} -- Factory

	new_namespace_name: XF_PARSER_NAME is
			-- Create namespace_name.
		do
			!! Result.make
		ensure
			new_object: Result /= Void
			empty: Result.is_empty
		end

	new_name_set: DS_HASH_SET [XF_PARSER_NAME] is
			-- Name set for checking.
		do
			!! Result.make_equal (0)
		end

feature {NONE} -- DTD

	set_element_repetition (a_node: XM_DTD_ELEMENT_CONTENT; a_value: CHARACTER) is
			-- Set repetition status of a node.
		require
			node_not_void: a_node /= Void
		do
			a_node.set_one
			inspect a_value
			when '+' then a_node.set_one_or_more
			when '?' then a_node.set_zero_or_one
			when '*' then a_node.set_zero_or_more
			end
		end

	element_name (a_name: STRING): XM_DTD_ELEMENT_CONTENT is
			-- Make element content name node.
		require
			not_void: a_name /= Void
		do
			!! Result.make_name (onstring (a_name))
		ensure
			not_void: Result /= Void
		end

	on_attribute_declarations (ele_name: STRING; some_attributes: DS_LINEAR[XM_DTD_ATTRIBUTE_CONTENT]) is
			-- Send all element declarations.
		require
			ele_not_void: ele_name /= Void
			atts_not_void: some_attributes /= Void
		local
			a_cursor: DS_LINEAR_CURSOR[XM_DTD_ATTRIBUTE_CONTENT]
		do
			from
				a_cursor := some_attributes.new_cursor
				a_cursor.start
			until
				a_cursor.after
			loop
				-- TODO: missing part
				on_attribute_declaration (onstring (ele_name), a_cursor.item.name, a_cursor.item)
				a_cursor.forth
			end
		end

feature {NONE} -- Entities

	new_literal_entity (a_value: STRING): XF_ENTITY_DEF is
			-- New literal entity definition.
		require
			not_void: a_value /= Void
		do
			!! Result.make_literal (a_value)
		end

	new_external_entity (a_value: XM_DTD_EXTERNAL_ID): XF_ENTITY_DEF is
			-- New external entity definition.
		require
			not_void: a_value /= Void
		do
			!! Result.make_external (a_value.system_id.to_utf8)
		end

feature {NONE} -- Entities

	when_entity_declared (a_name: STRING; a_def: XF_ENTITY_DEF) is
			-- Entity has been declared.
		require
			name_not_void: a_name /= Void
		do
		 	debug ("xml_parser")
				io.put_string ("Entity declared: ")
				io.put_string (a_name)
				io.put_string (" value: ")
				io.put_string (a_def.value)
				io.put_new_line
			end
			
			-- 4.2: when multiple declaration first one is binding
			if a_def /= Void then
				if not entities.has (a_name) then
					entities.force (a_def, a_name)
				end
				check has: entities.has (a_name) end
			end
		end
		
	when_pe_entity_declared (a_name: STRING; in_def: XF_ENTITY_DEF) is
			-- PE entity has been declared.
		require
			name_not_void: a_name /= Void
		local
			a_def: XF_PE_ENTITY_DEF
		do
		 	debug ("xml_parser")
				io.put_string ("PE entity declared: ")
				io.put_string (a_name)
				io.put_string (" value: ")
				io.put_string (in_def.value)
				io.put_new_line
			end

			-- 4.2: when multiple declaration take first one
			if in_def /= Void then
				-- convert to PE
				!! a_def.make_def (in_def)
				if not pe_entities.has (a_name) then
					pe_entities.force (a_def, a_name)
				end
				check has: pe_entities.has (a_name) end
			end
			
		end

	entity_referenced_in_entity_value (a_name: STRING): STRING is
			-- Named parameter entity has been referenced in entity value.
		require
			not_void: a_name /= Void
		do
			if in_external_dtd then
				if pe_entities.has (a_name) then
					Result := defined_entity_referenced (pe_entities.item (a_name))
				else
					-- 4.4.4 Forbidden
					force_error (Error_external_reference_in_quoted_value)
				end
			else
				force_error (Error_doctype_peref_only_in_dtd)
			end
		end

	defined_entity_referenced (a_def: XF_ENTITY_DEF): STRING is
			-- Resolved defined entity in quoted value.
		require
			not_void: a_def /= Void
		do
			if a_def.is_literal then
				-- 4.4.5 Included in literal
				Result := a_def.value
			else
				Result := external_entity_to_string (a_def.value)
			end
		end

	external_entity_to_string (a_sys: STRING): STRING is
			-- External entity to string.
		require
			not_void: a_sys /= Void
		local
			a_file: XF_UTF16_INPUT_STREAM
			an_error: STRING
		do
			Result := clone ("")
			!! a_file.make (a_sys)
			if a_file.is_open_read then
				-- inefficient?
				from until
					a_file.end_of_input
				loop
					a_file.read_character
					Result.append_character (a_file.last_character)
				end
			else
				an_error := clone (Error_cannot_read_file)
				an_error.append_string (": ")
				an_error.append_string (a_sys)
				force_error (an_error)
			end
		end

feature {NONE} -- DTD

	when_external_dtd (a_system: XM_DTD_EXTERNAL_ID) is
			-- Load external DTD from system name.
		require
			system_ok: a_system /= Void
			has_system: a_system.system_id /= Void
		do
			debug ("xml_parser") io.put_string ("[when_external_dtd]") end
			
			-- push old scanner
			scanners.force (scanner)
			!XF_SCANNER_DTD! scanner.make_scanner
			scanner.set_input_file (a_system.system_id.to_utf8)
			if not scanner.last_input_file_opened then
				on_error (Error_cannot_open_external_dtd)
			end
		end

feature -- Parser

	parse_file (a_name: STRING) is
			-- Parse file.
		require
			not_void: a_name /= Void
		do
			on_start
			scanner.set_input_file (a_name)
			if scanner.last_input_file_opened then
				parse
			else
				force_error (Error_cannot_read_file)
			end
			on_finish
		end

	parse_stream (a_stream: KI_CHARACTER_INPUT_STREAM) is
			-- Parse XML Document from GOBO input stream.
			--
		require
			a_stream_not_void: a_stream /= Void
		do
			on_start
			scanner.set_input_buffer (scanner.new_file_buffer (a_stream))
			parse
			on_finish
		end

feature -- Errors
	
	force_error (a_message: STRING) is
			-- Report error message.
		do
			on_error (a_message)
			abort
		end

feature {NONE} -- Scanner implementation

	make_scanner is
			-- Initialise main scanner and saved
			-- scannners stack.
		do
			!! scanner.make_scanner
			!! scanners.make
		end
		
	scanner: XF_FULL_SCANNER
			-- Scanner for PE entity.

	scanners: DS_LINKED_STACK[XF_FULL_SCANNER]
			-- Scanner stack for entities etc.

	last_token: INTEGER
			-- Last token read by read_token.
	last_value: ANY
			-- Last value read by read_token.

	read_token is
			-- Read token from scanner.
		do
			-- read token from scanner
			scanner.read_token
			last_token := scanner.last_token
			last_value := scanner.last_value
			
			debug ("xml_parser")
				io.put_string (token_name (last_token))
				io.put_string ("/")
				if last_value /= Void then
					io.put_string (last_value.out)
					io.put_string ("!")
				end
			end
			
			-- unwind scanner stack if end of current one
			if scanner.end_of_file and not scanners.is_empty then
				scanner := scanners.item
				scanners.remove
				read_token
			end
			
			-- if this is a PE entity reference, temporarily
			-- switch scanner. Token is left for validation.
			if last_token = DOCTYPE_PEREFERENCE then
				process_pe_entity (last_value.out)
			-- same if content entity reference
			elseif last_token = CONTENT_ENTITY  then
				process_entity (last_value.out)
			elseif last_token = ATTRIBUTE_ENTITY then
				process_attribute_entity (last_value.out)
			end
		end

feature {NONE} -- Scanner entity processing

	process_pe_entity (a_name: STRING) is
			-- Pushn PE entity scanner on stack.
		require
			not_void: a_name /= Void
		do
			if pe_entities.has (a_name) then
				process_entity_scanner (pe_entities.item (a_name))
			else
				force_error (Error_doctype_undefined_pe_entity)
			end
		end

	process_entity (a_name: STRING) is
			-- Push entity scanner on stack.
		require
			not_void: a_name /= Void
		do
			if entities.has (a_name) then
				process_entity_scanner (entities.item (a_name))
			else
				-- 4.4.4 Forbidden
				force_error (Error_entity_undefined)
			end
		end

	process_attribute_entity (a_name: STRING) is
			-- Push entity scanner on stack.
		require
			not_void: a_name /= Void
		do
			if entities.has (a_name) then
				if entities.item (a_name).is_literal then
					process_entity_scanner (entities.item (a_name))
				else
					force_error (Error_entity_literal_in_attribute)
				end
			else
				-- 4.4.4 Forbidden
				force_error (Error_entity_undefined)
			end
		end

	process_entity_scanner (a_def: XF_ENTITY_DEF) is
			-- Save previous scannner, create new scanner, and
			-- reset it with previous scanner state. 
		require
			not_void: a_def /= Void
		do				
			a_def.apply_input_buffer
				
			if a_def.has_error then
				force_error (a_def.last_error)
			else
				-- push scanner
				a_def.set_start_condition (scanner.start_condition)
				scanners.force (scanner)
				scanner := a_def
			end
		end

feature -- Error diagnostic

	line: INTEGER is
			-- Current line.
		do
			Result := scanner.line
		end

	column: INTEGER is
			-- Current column.
		do
			Result := scanner.column
		end

	byte_position: INTEGER is
			-- Current byte index.
		do
			Result := scanner.position
		end

	filename: STRING is
			-- Current file.
		do
			Result := scanner.filename
		end

	error_header: STRING is
			-- Header for error message.
			-- <filename>:<line>:<column>:
		do
			Result := clone (filename)
			Result.append_string (":")
			Result.append_string (line.out)
			Result.append_string (":")
			Result.append_string (column.out)
			Result.append_string (":")
		ensure
			not_void: Result /= Void
		end

feature {NONE} -- String

	concatenate (a, b: STRING): STRING is
			-- Result := a + b
		require
			not_void: a /= Void and b /= Void
		do
			Result := clone (a)
			Result.append_string (b)
		end

	shared_empty_string: STRING is
			-- Shared empty string. 
		once
			Result := clone ("")
		end

	onstring (a: STRING): UC_STRING is
			-- Convert string from inside the parser to string as 
			-- seen by callback interface.
		do
			if a /= Void then
				Result := new_unicode_string_from_utf8 (a)
			end
		end

invariant

	scanner_not_void: scanner /= Void
	scanners_not_void: scanners /= Void

end
