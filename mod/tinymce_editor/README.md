<!--
# @title README - mod: tinymce
-->
# TinyMCE mod

TinyMCE is an embeddable WYSIWYG editor written in JavaScript. This mod makes TinyMCE
usable within decko and extends its capabilities to support ui for nesting and other
card references.


| codename | default name | purpose                       |
|:---------|:-------------|:------------------------------|
| tiny_mce | *tinyMCE     | configuration card for editor |


## Sets with code rules

### {Card::Set::All::TinymceEditor}

Adds tiny_mce input type.

### {Card::Set::All::ReferenceEditor}

Extends TinyMCE editor with ui for card reference syntax, including nesting and links.