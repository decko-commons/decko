# Notify

Follow cards, get notified when they change.

## Sets

Cards ruling notifications include:

### Follow preferences (or follow rules)
| name | type | content |
|:----:|:----:|:-------:|
| [Set]+[User]+:follow | Pointer |list of follow options|

Each rule determines cases in which the _User_ should be notified about changes to the _Set_.

### Follow options
| name | type | content |
|:----:|:----:|:-------:|
|\*_optionname_| Basic | (blank)

Each follow preference can point to one or more of the following follow options.

- _always:_ notify user after every create, update, and delete 
- _never:_ do not notify user
- _created:_ notify user when a card is created
- _edited:_ notify user when a card is created or updated

### Follow dashboard
| name | type | content |
|:----:|:----:|:-------:|
|[User]+:follow|Pointer(virtual)|list of sets

Core view shows Follow and Ignore tabs.  Each tab has a list of the 
user's preferences in `follow_item` view.

Views include:
- _follow_tab_
- _ignore_tab_

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

