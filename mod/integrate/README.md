<!--
# @title README - mod: integrate
-->
# Integrate mod

The integrate mod supports the configuration of special events in cards.


| codename  | default name | purpose                            |
|:----------|:-------------|:-----------------------------------|
| on_create | *on create   | execute event when card is created |
| on_update | *on update   | execute event when card is updated |
| on_delete | *on delete   | execute event when card is deleted |

An integration rule specifies a list of events to be triggered when 
a card action is taken. 

So, for example, if the `Signup::type:on_create` contains an email template, then the 
email is sent out whenever a signup card is created.

Any card that implements a `#deliver` method can serve as an action in an integration 
rule. In default decko installations, the two kinds of items in integration rules are 
Email Templates and Notification Templates

The {Card::Set::All::Observer} mod implements an observer that notices when a relevant
card is created, updated, or deleted. In such cases the triggering card (eg one newly 
created) is sent as an an argument to the `#deliver` method, which is called upon
the cards listed by the integration rule.

