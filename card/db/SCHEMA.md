# Decko/Card Schema

The Decko/Card schema, like everything in Decko, revolves around the *card*. Any time a column ends in `_id` but begins with a term that doesn't directly match another table, that column always refers to a card id. For example, `left_id`, `right_id`, and `type_id` all refer to card ids.

## Cards

Cards can contain multiple unique identifiers. All cards in the database have a numerical `id`. (Virtual cards, which are creating by patterned card name combinations, are not in the database and thus have no `id`).

In concept, all cards have a `name`. But, perhaps surprisingly, not all cards have a value in the `name` column of the cards table. That's because cards with compound names store the ids of their left and right names (`left_id` and `right_id`), from which their names can then be generated. For example, for a card named "Tito+address", the `name` field would be null, the `left_id` would be the `id` of the card named "Tito", and the `right_id` would be the name of the card named "address".

All cards with a stored `name` will also store their `key`. The `key` is a standard lowercase-and-underscore name variant that makes it possible to look cards up by _any_ variant of the name. For example, if a card is named "Hi, Mom!", its key will be `hi_mom`. That way you can look up "HI MOM" or "hiMom" or "Hi? Mom???", and they will all find the same card, which will retain the same authoritative `name` ("Hi, Mom!").

One final identifier, the `codename`, makes it possible to refer to cards directly by name in the codebase. (Code should never directly refer to a card's `name`, lest the code break if/when the name is changed.) The vast majority of cards will not have a codename; no compound cards should ever have one.

The `creator_id` and the `updater_id` columns refer to the cards associated with user accounts who created and last edited the card respectively. `created_at` and `updated_at` refer to the dates/times of those events.

Every card has a cardtype, and the `type_id` refers to the card associated with that cardtype. Every card also has a content. The reason the database is entitled `db_content` is to handle cases (such as Files and Images) where the content in the database requires some manipulation to find/generate the actual card content.

The `trash` field is a boolean to identify cards that have been "deleted" (added to the trash). 

The `read_rule_class` and `read_rule_id` are part of the permissioning system and make it possible to query only for cards that a given user has permission to read. Such queries gather a list of all rule cards that would allow them to read the card and restrict to results to cards whose governing `read_rule_id` is in that list. (The `read_rule_class` is used to optimize rule updates.)

## Card Acts, Actions, and Changes

Together with cards, acts, actions, and changes comprise our card history system.

Any time you create, update or delete anything, there is an act. The act stores an `actor_id` (who did it) and an `acted_at` (when they did it). It also stores an `ip_address`, which can be useful for detect malicious actors, but which many choose to delete periodically for data privacy reasons. Finally, it stores a `card_id`, which we'll wait a whole paragraph to explain.

Any given act can involve many actions, and each action is associated with one and only only card. A user might submit a form that creates 5 cards. That's one act and five actions. Another act might update 2 cards and create 4 more (6 actions). The action's `card_id` refers to the card created, updated, or deleted. The `card_act_id`, of course, refers to the act that contains all the actions. The `action` type is create, update, or delete. A `draft` is a non-final action. The `comment` field is basically unstructured metadata, used for example to add the original filename in a file upload. Finally, the `super_action_id` comes into play when one action triggers another. The "super action" triggers the "sub action."

Back to that `card_id` on the card_acts table. When you initiate an act, for example by submitting a web form, the act is always performed on a specific card. But that card is not necessarily one of the action cards. For example, I might submit a form where the card in question is "Tito" but only "Tito+address" is changed. Tito is the card identified by the `card_id` of the act, but "Tito+address" is the card identified by the `card_id` of the action.

The final table in the history system is the card_changes table, which is where the actual changes to field values are tracked. The `card_action_id` is the id of the action, the field is an integer (0-5) representing, in order, the following six fields in the cards table: `name`, `type_id`, `db_content`, `trash`, `left_id`, or `right_id`. As an optimization, no change is stored upon the initial creation. All initial values are stored (associated with the creation action) after the first update action.

## Card References

When the content of one card refers to another card, this is tracked as a _reference_. For example, if a card named "Grocery List" contains a link (in card link syntax) to `[[Apple]]`, then decko tracks a reference from "Grocery List" to "Apple". This can then be used to quickly query cards that refer to "Apple" or are referred to by "Grocery List" without further content parsing.

The `referer_id` is the id of the card that does the referring ("Grocery List" in our example). The `referee_id` is the card referred to ("Apple"). For cases where the card referred to doesn't have an id (a classic wiki pattern is to link to cards that don't exist) we store a `referee_key`. The `ref_type` is one of the following:

- **L**: a link
- **I**: a nest (we used to call them "inclusions")
- **S**: a search (eg, `{ type: "Image" }` refers to the Image card)
- **P**: partial (stored when we have ids for parts of the referee but not the whole. Eg, the card named "Image+:self" likely doesn't have an id, but both `Image` and `:self`, so partial references are tracked to each.)
