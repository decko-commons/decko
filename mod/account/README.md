<!--
# @title README - mod: account
-->
# Account mod

_Create and manage accounts with cards._ 

Like everything else in Decko, accounts are encoded using cards. A high-level
introduction to account handling in Decko is available at https://decko.org/account

## Sets

|           name            |           important fields            |
|:-------------------------:|:-------------------------------------:|
| [accounted card]+:account | :email, :password, :salt, and :status |

Accounts themselves are stored in `+:account` cards. While it is most common
(and best supported) for `User` cards to have accounts, it is possible for any
card to have an account, if they include the `Card::Set::Abstract::Accountable` set.
This can be useful for decks on which it is desirable 
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

A new default deck comes with the following two cards:

- **Anonymous** - Edits made by people who are not signed in are credited to Anonymous
- **Decko Bot** - A fully permissioned card to which many generic actions are attributed.

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

Roles are tools for grouping accounted cards for the sake of assigning permissions. 
Each Role card can have a *List* of members.

The account mod comes with several built-in roles:

Two have implicit member handling:

- **Anyone** - Every accounted card automatically has this role. A permission given to 
  *Anyone* is unrestricted.
- **Anyone Signed In** - Everyone signed in has this role

Another has implicit permission handling:
- **Administrator** - Can create, read, or update any card

And others have no special code attached to them, but they come with handy default
settings:
- **Eagle** - typically used for content editors
- **Shark** - typically used for those editing rules, like structure, defaults, styling,
  etc.
- **Help Desk** - someone who can assign roles and edit user permissions.


|  name   | codename |   type    | important fields |
|:-------:|:--------:|:---------:|:----------------:|
| Sign Up |  signup  | Cardtype  |     :account     |
|  User   |   user   | Cardtype  |     :account     |  

When you sign up for Decko, you create a new `Sign Up` card. A successful signup is 
then converted into a User card (as in, its type changes from `Sign Up` to `User`.)

Permissions on these cards determines how accounts are created:

- If Anyone can create a Sign Up card, then anyone can sign up. 
- If Anyone can create a User card, then users can verify their own accounts (via email)
- If NOT Anyone can create a User card, then accounts must be approved by an existing user
  who has the permission to create a User card.

### Other special cards

- Signing in and out is performed using the `:signin` card. Signing in works by initiating
an update action on the card, and signing out works by initiating a delete action. (In
neither case is the `:signin` card actually altered; the action is aborted once
the authentication takes place)

- The `:account_settings` card can be appended to any accounted card to provide UI
  for various account-related content.