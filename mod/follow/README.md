<!--
# @title README - mod: follow
-->
# Follow

Follow sets cards, get notified when any card in the set changes.

## Sets

Cards ruling notifications include:

### Follow preferences (or follow rules)

| name | type | content |
|:----:|:----:|:-------:|
| [Set]+[User]+:follow | Pointer | list of follow options |

Each rule determines cases in which the _User_ should be notified about changes to the _Set_.

These cards have special permission handling, granting full permission to the _User_.

Special views include:

- *follow_item*
- *follow_status*

### Follow options

| name | type | content |
|:----:|:----:|:-------:|
| \*_optionname_| Basic | (blank) |

Each follow preference can point to one or more of the following follow options.

- _always:_ notify user of changes to all cards in set 
- _never:_ do not notify user of changes to card in set
- _created:_ notify user of changes to cards user has created
- _edited:_ notify user of changes to cards user has edited 

### Follow dashboard

| name | type | content |
|:----:|:----:|:-------:|
| [User]+:follow | Pointer(virtual) | list of sets |

Core view shows Follow and Ignore tabs.  Each tab has a list of the 
user's preferences in `follow_item` view. Navigate to this card via the
card submenu (`account > follow`).

Special views include:
- *follow_tab*
- *ignore_tab*

### Follow suggestions

| name | type | content |
|:----:|:----:|:-------:|
| :follow_suggestions | Pointer | list of follow settings |

This advanced global setting lets sharks determine what suggestions will appear on the
follow dashboard.  Any item not currently followed will be suggested.

Each suggestion can take the form of either `[Set]` or `[Set]+[Follow Option]`.

### Following status

| name | type | content |
|:----:|:----:|:-------:|
| +:following | Pointer(virtual) | card's follow status for current user |

With this card, users can see and/or edit whether they are following the 
card in question.

This view is seen via the "follow" item in the main card menu or via
`activity > follow` in the submenu.

Special views include:
- _core_ a follow edit interface if signed in
- _status_

### Followers

| name | type | content |
|:----:|:----:|:-------:|
| +:followers | Pointer(virtual) | list of users |

User who are following the card in question.

(not integrated into interface)

### Email template

| name | type | content |
|:----:|:----:|:-------:|
|follower notification email|Email Template|(nested email config)|

The _to_ field is handled automatically. All other fields can be sharked.

Useful views added by this mod include:

- _list_of_changes_ (updates coming soon)
- _subedits:_ (updates coming soon)
- _followed:_ label of set followed
- _unfollow_url:_ link to remove the following rule that led to this email

### Follow fields

| name | type | content |
|:----:|:----:|:-------:|
| [Set]+:follow_fields | Pointer (rule) | list of fields |

These rules rules are advanced configuration that let sharks determine which of a card’s fields
are automatically followed when a user follow that card.

The default value is `:nests`, which means that nested cards are followed by default.

## Lib

### Card::FollowerStash

A class for stashing followers of a given card.

### Card::FollowOption

A module for tracking and grouping follow options and their processing code.


## TODO
- review / address follow references in:
  - rich_html/
    - menu
    - toolbar
  - all/rules
  