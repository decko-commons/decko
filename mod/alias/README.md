<!--
# @title README - mod: alias
-->

# Alias Mod
Enable Alias cards, which alias one simple card name to another.

The primary use case for alias cards is for handling redirects, for example after a card 
has been renamed. Suppose, for example, a card's name is changed from *Former* to
*Current*. One can create an Alias card named "Former" with the content "Current". This
not only insures that links to /Former will be redirected to /Current, but it also 
handles all descendants, redirecting /Former+field to /Current+field and /My+Former+Life
to /My+Current+Life.

Alias cards themselves must be simple cards and are not allowed to have children.

If a request to an alias specifies a view, eg `/Former?view=edit`, then the request
will not be redirected and will instead return the view of the Alias card itself. 
Similarly, transactional requests (create, update, and delete) to the alias card
will take effect on the alias, not the target.

## Cards with codenames

| codename | default name | purpose |
|:--------:|:------------:|:-------:|
| :alias | Alias | Cardtype of aliases |

## Sets with code rules

### {Card::Set::Type::Alias type: Alias}
An alias card's name is the alias's *source*, and its content is its target. So, in the 
example above, the Alias card would be named *Former* and its content would be *Current*.

Content is stored as a card id.

#### Events

| event name | when | purpose |
|:---------:|:------:|:-------:|
| validate_alias_source | on save | ensures name is simple and card has no children |
| validate_alias_target | on save | ensures target is existing simple card |

### {Card::Set::All::Alias All}

#### Events

| event name | when | purpose |
|:---------:|:------:|:-------:|
| create_alias_upon_rename | triggered | creates an alias from old name to new one |


#### HtmlFormat
Extends `#edit_name_buttons` so that when renaming, user is presented with a checkbox 
to trigger the creation of an alias

### {Card::Set::AllPlus::Alias All Plus}
Handle aliasing of compound names when at least one name part is an alias.

#### Events

| event name | when | purpose |
|:---------:|:------:|:-------:|
| validate_not_alias | on save | prevents creation of deescendents of aliases |

## {CardController::Aliasing}
Module that enables card controller to handle alias-driven redirects and ensure that 
transaction requests act upon the correct card (the alias when simple, the target when
compound).
