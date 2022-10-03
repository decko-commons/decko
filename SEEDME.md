# Seeding Cards

## I just want to seed my deck

If you're starting from scratch, run `decko setup`. This will create the databases
specified in your database.yml, the tables specified in the decko schema, and the
data specified in the mods.

If you have recently added a mod and need to take in its seed data, run `decko update`.

If you already have tables but want to start over, you can use `rake card:seed:replant`,
which will truncate (as in, delete everything from) the existing tables and then
add the seed data.

You can also use Ruby-on-Rails db tasks (eg `db:reset`, `db:drop`) for their original
purpose, but caution is advised.

**IMPORTANT**: always back up any valuable data before running any seed commands.

_The remainder of these docs are intended as an introduction for Monkeys who may be
creating or modifying seed data. You probably don't need it if you're working exclusively
as a Shark._

## Background: seeded cards often connect code with data

Decko blurs the line between data and code. That is by design, because Decko helps people
who aren't coders do things that usually only coders do. In Decko terms, we extend the
capacities of sharks (ie advanced web users, so ultimately **data** people) into the
realm of the capacities of monkeys (ie **code** people).

[Mods][1] often add cards used to configure things. These cards can
be influenced in data (by sharks), in code (by monkeys), or both. Cards that are
referred to in code have a **codename** used by coders, and those cards are generally
added to decks via seeding.

**IMPORTANT**: Monkeys (coders) should never refer to a card in shared code by its name
(which can change) or its id (which can vary from site to site). Instead, they should
always use a **codename**, which is an independent permanent identifier. Often a card's
codename is the same as its name, but if a user changes the name, the codename remains the
same, so the connection to the code is not broken.

## How seeding works

### Fixtures

#### _Fast to load, hard to write._

Fixtures are fast-loading YAML files that are used by important tasks like `decko setup`
and `rake card:seed:replant`.

Every deck is configured with a list of mods that contain fixtures. You can configure that
list in `config/application.rb` or environment-specific
config files using `config.seed_mods`. To see the current mod list, you can run
`decko runner 'puts Cardio.config.seed_mods'`. A default installation will return the
following:

```
defaults
core
```

This tells you:

1. Running `be decko setup` will use fixtures from the **defaults** mod, the first mod on
   the list. To see those fixtures, look in the `data/fixtures` directory of the defaults
   mod in the card gem. (You can use `rake card:mod:list` to see where all your mods are
   installed.)
2. The defaults mod's seed data is generated using seed data in the **core** mod.

If you were to look in the `data/fixtures` directory of either the _core_ mod or the
_defaults_ mod, you would find directories of yaml files that correspond to tables in
the database.

The deck described in the _core_ mod is very small: just 11 cards. This is the minimal
seed dataset, and it is the only one in which these fixtures files are edited by hand.
Here is one example of a card in cards.yml:

```
list:
   id: 4
   name: List
   key: list
   codename: list
   creator_id: 1
   updater_id: 1
   read_rule_class: all
   read_rule_id: 10
   trash: false
   type_id: 3
   db_content: ""
```

For a card's representation to be complete, we also need to represent the action
that created it, the act of that action, and any references it makes to other cards.
Each of these involves **lots of ids and repeated fields that are very easy to get wrong
when working by hand.** So generally speaking, the fixtures in the core mod are the _only_
fixtures that ever get edited by hand (and even that is very rare).

### Pods

#### _Easy to use._

Because of fixtures' complexity, we almost always generate fixtures from simpler YAML
files in mods' data directories. The data in these "pod" files are based not on the final 
database structure but on the api by which cards are created.

For example, here is how that same card would look in pod yaml:

```
- :name: List
  :codename: list
  :type: :cardtype
```

Here's how the fixtures in the `defaults` mod are generated:

1. seeding from the fixtures `core` mod
2. "eating" the seed data in all the mods that the `defaults` mod depends on
3. dumping the results to fixtures

> #### Why pods?
> Pod data are used not only in generating fixtures but also in **mod installation**
> and **code
updates**. The idea is that for most cases you only need to **manage mods' card
data in one place.**

There are two main ways to generate seed pods:

1. Write it by hand
2. Export it from your deck using `card sow`

_(See `card sow -h` for more)_

Pods can use all the same arguments that are used with `Card.create` or `card.update`.
The most common are:

- name
- type
- codename
- content
- fields
- skip
- trigger

You can also use `user` to specify who should perform the action.

The standard way to ingest card pods is by using `decko update`, but you can also
use `card eat` for more control over your meal.

### _Real_ vs _Test_ data

Test data is dummy data added to facilitate code testing. It is not intended to be
included in live sites. _Real_ data, by contrast, _is_ intended for production sites.

When you add seed data to mods, you typically put it in one of two files:

- data/real.yml
- data/test.yml

If you have a _lot_ of data, you can break them into more files. For example if you want
to add "project" data, you can add them to a file called `data/real/projects.yml` and then
add a line with `- projects` in the real.yml file.

### Updating fixtures

The primary rake task for updating seed fixtures is `card:seed:build`. When pods are
updated, you will need to run this `build` task in order for the fixtures to be updated
and any changes to be reflected in the seed data.

When the build task is run, it:

- populates the seeds from the fixtures set it depends on
- ingests all the applicable pods
- finalize seed data with migrations, installations, etc
- dumps new fixtures.

For any given fixtures set, the _test_ data depends on the _real_ data in that set. So
for changes in _real_ pod data to show up in _test_ data, one must first rebuild the
_real_ fixtures, and then rebuild the _test_ fixtures that depend on them.

## Creating a new fixtures set

#### _For advanced monkeys_

Fixtures sets are for packaged deployments of specific applications that combine many
mods.

Let's say you're creating a site called `mydeck`, and you want to install multiple copies
of that deck with the same seed data. Here's how:

1. Choose a mod where you want to save the seed fixtures and add the required
   directories in `[mymod]/data/fixtures`
2. Add the following line to `config/application.rb`:
   ```
   config.seed_mods.unshift :mymod
   ```
3. Run `rake card:seed:build`

This will generate fixtures that include all your data in addition to the data from the
defaults mod.

Once you have your fixtures in place, you can use `rake card:seed:update` for most
changes. This will add and update seed data but won't remove any old data. If you have
old data to remove, you will need to run `rake card:seed:build` again to build from
scratch.

If you would like to publish your new seed data in a gem mod, then rather than
configuring the seed mod list in `config/application.rb`, you will need to configure it
in the gem's default required ruby file.

For example if you create a gem mod called `card-mod-mymod`, then inside
`lib/card/mod/mymod.rb` you will want something like the following:

```
Cardio::Railtie.config.seed_mods.unshift :defaults
```

[1]: https://github.com/decko-commons/decko/blob/main/card/lib/cardio/mod.rb
