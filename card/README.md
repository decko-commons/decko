<!--
# @title README - Card
-->
# A Developer's introduction to the Decko/Card code base

New folks should start here after playing with Decko but before digging into
code.

## Intro

### Am I in the right place?

Yes, if:

*   **You're a Ruby developer**, or at least someone who does not fear ruby
    code. **Not a techie? [Try Decko.org](http://decko.org)**
*   **You've experimented with Decko** enough to know the basics
    ([cards](docs/Card), types, rules, etc.) **No idea what a card is? [Try
    Decko.org](http://decko.org)**.
*   **You're looking at this page from a docs site** (ie, NOT GitHub) so you
    can use our links to navigate code. **Links look funny? [Try
    rubydocs.info](http://docs.decko.org/gems/card).**

### Decko: an *application* or a *development framework*?

It's both.

When you install and seed a new Decko project, you have a working "deck" right
away. Your new application has a lot built in: account handling, edit
histories, default layouts, CSS, etc. But a new deck is just a starting point.
Decko offers a rich framework within which to develop your own novel
applications, both **via configuration (as a "Shark")** or **via code (as a
"Monkey")**.

**Decko is a development framework in which you start *in the middle of
things* rather than from scratch**. Decko gives you a headstart, so that
designers, developers, and content creators can start working in parallel on
day one. But from there, you can build (or remove) pretty much whatever you
want.

### Decko: Ruby on Rails?

Ruby-on-Rails developers reading this will find lots of familiar patterns in
Decko, which indeed depends upon rails gems. **Although Decko is a Rails
descendant and owes a ton to the Rails community, it is not Rails.** Unlike
Rails, Decko is not an implementation of the "MVC" (Model-View-Controller)
architectural pattern (see Architecture below). More concretely, while Rails'
core pattern is adding new things (especially models, views, and controllers),
Decko's core pattern is subdividing existing things into new Sets.

Deck-coders do create lots of card views (though they're quite different from
Rails views), but we rarely if ever create new controllers or ActiveRecord
models. In the Decko gem there is one controller (CardController) and one main
model ({Card}). Other models optimize the Card model and track its history:
(See {Card::Reference references}, {Card::Act acts}, {Card::Action actions},
and {Card::Change changes}).

### Cards, Sets, and Rules

{Card *Cards*} are the basic building blocks of Decko. {Card::Set *Sets*} are
the basic pattern for organizing cards. **Both Sharks and Deck-coders create
web systems by applying *rules* to *sets* of *cards*.**

If you've edited card rules in any deck, you will have encountered Sets. For
example, imagine you're on a User card named "Henry", and you decide to edit
its structure. When you do, you'll be prompted to choose the Set of cards to
which the structure rule applies, eg:

*   Just "Henry"
*   All Users
*   All Cards

The Rule in question will apply to all cards in the set you choose. If a card
has rules in more than one set, the rule applied to the narrower set overrides
the rule applied to the broader one.

This same general pattern occurs in Decko code: code rules (methods) are
organized under the Set of cards to which they apply. This means both code
rules and card (data) rules) can be as narrow or specific as desired.

## Architecture

Sets are central to Decko's architecture, which follows a new pattern that we
call *MoFoS*. MoFoS stands for "Model-Formats-Sets": One **Mo**del, viewable
in many {Card::Format **Fo**rmats}, divisible into {Card::Set **S**ets}.

In Decko, the MoFoS "model" is, as you may have guessed, the {Card *Card*}.
We've just explore {Card::Set *Sets*} above.  But what are {Card::Format
Formats}?

You may have noticed that you can add .html (the default), .text, .json, etc
to any card's web path to receive the card's contents in a different file
format. These are achieved by {Card::Format Format} classes. HTML, Json, Text,
etc each has its own Format class.

In keeping with this architecture, Decko's code is heavily organized around
correlating Ruby classes for the model and formats:

1.  the "model" is {Card}
2.  the "formats" are {Card::Format} and its descendants

Sets are implemented not as Ruby classes but as Ruby modules that are included
in applicable card and format objects. For example, when fetching the "Henry"
card, the Card object's singleton class will include the module
Card::Set::Type::User.  And when rendering a view of that card in Html, the
format object will include Card::Set::Type::User::HtmlFormat. That's a
mouthful. It's also something you'll never have to write (or think about
really), because Set functionality is almost always developed using our Set
DSL, which automatically handles the ruby module naming based on the file
name.

Cards, Formats, Sets, and other structures can all be developed via {Card::Mod
Mods}.

## Mods

{Card::Mod Card Mods} (short for *modules* or *modifications*) are the primary
mechanism for developing and sharing Decko code. If you're just getting
started as a Decko developer, learning about {Card::Mod Mods} is a great next
step.
