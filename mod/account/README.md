<!--
# @title README - mod: account
-->
# Account mod

_Create and manage accounts with cards._ 

Like everything else in Decko, accounts are encoded using cards.

## Sets

|           name            |           important fields            |
|:-------------------------:|:-------------------------------------:|
| [accounted card]+:account | :email, :password, :salt, and :status |

Accounts themselves are stored in `+:account` cards. While it is most common
(and best supported) for `User` cards to have accounts, it is possible for any
card to have an account. This can be useful for decks on which it is desirable 
to assign accounts to, for example, companies or robots, but it is not desirable
to treat such entities as "users."

Because (in the wiki tradition) Decko attributes changes to community members who make
them, it is typically important not to delete cards of former users, lest their changes 
be unattributed, creating confusing, misleading, or potentially even malicious gaps in
the record.

However, it is possible to delete the _account_ without deleting the _accounted_ card.
For example, if `Malik` is a user and wishes to have his account deleted, this can be
achieved by deleting `Malik+:account`. The email and passwords associated with the 
account will be deleted, but Malik's name will remain in the system so that his 
edits can still be attributed.

### Account fields

All account fields include the `Card::Set::Abstract::AccountField` set, which 
makes content editable by the account owner

|  name   |  type   |   content    |
|:-------:|:-------:|:------------:|
| +:email | phrase  | email string |

Email cards are validated as valid email strings.


|    name    |  type   |     content     |
|:----------:|:-------:|:---------------:|
| +:password | phrase  | password string |

Password cards are validated as valid password strings.

### Other types

| name |   type   |      important fields      |
|:----:|:--------:|:--------------------------:|
| Role | Cardtype | :members (those with role) |

