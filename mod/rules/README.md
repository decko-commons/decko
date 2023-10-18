<!--
# @title README - mod: rules
-->
# Rules mod

Card rules apply settings to specific Sets of cards. The Set can be as specific as a 
single card or as general as all cards. Rules on narrower Sets take precedence over rules
on broader ones.

The rules mod adds code for managing card rules.

| codename | default name | purpose                                               |
|:---------|:-------------|:------------------------------------------------------|
| set      | Set          | cardtype for representing configurable group of cards |
| setting  | Setting      | cardtype for rule configuration options               |

The basic pattern for rules is `Set+Setting`.  For example, the rule card `:all+:read` 
represents the default read permission rule for all cards.

## Sets with code rules

