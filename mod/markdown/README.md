<!--
# @title README - mod: markdown
-->
# Markdown mod

Markdown is a popular plain-text syntax that can easily be converted into HTML. 
Sort of an HTML shorthand.

This mod adds a Markdown cardtype, with which card editors can save content as markdown 
and have that content rendered as HTML

## Sets modified

| type | content |
|:----:|:-------:|
| Markdown | plain text in Markdown syntax|

## Nests

Card nest syntax can be used within Markdown. Everything inside double curly brackets
(`{{ }}`) is ignored by the markdown processor, so any nest syntax that conflicts with 
markdown syntax (like the `*` in `{{*title}}`) doesn't have be escaped.
