<!--
# @title README - mod: monkey
-->

# Monkey mod

"Monkeys" are decko/card users who extend functionality by writing mod code using Decko's
DSL. This mod supports monkeys by:

- adding helpful gem dependencies to support debugging and consistent code styling
- providing code enhancements for debugging, especially via `+*debug` virtual cards.

## Sets modified

### All cards
| pattern |
|:----:|
| All |

#### (Experimental)
The `#events` and `#events_tree` methods help visualize the events that a card would 
execute for a given card action.

The `:views_by_name` and `:views_by_format` views show the views available for a 
given card.

### All +*debug cards
| pattern | anchor | codename |
|:----:|:----:|:----:|
| Right | *debug | debug |

#### (Experimental)
Add +*debug to any card to see information about sets, views, events, and cache usage.