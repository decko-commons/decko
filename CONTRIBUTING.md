# Thinking about contributing to Decko?
Nice! There's tons to do involving lots of different skillsets, and we welcome the help.

We want to make contributing to Decko as rewarding an experience as possible. Please 
jump in, and ask away for help.

## Sharks - Masters of Cards
Decko is built around the _card_ concept, so we call advanced users who create,
structure, organize, and maintain Decko websites "Card Sharks." There are many things
Sharks can do to contribute to the project: design, community support, documentation,
outreach, or even just the occasional kind word. 

Because Sharks live not in the land of code but in the sea of websites, we will
maintain information that pertains to them – **including installation troubleshooting, 
mod lists, and deck configuration** – on [Decko.org][1].

Sharks are invited to:

 - email the [Decko Sharks Google Group][2]
 - add issues to [GitHub's Issue Tracker][3]
 - sign up and contribute at [Decko.org][1]

## Monkeys - Makers of Mods
Mods (short for modules, modifications, modicum, whatever...) are the main 
mechanism for extending Decko behavior, and they're the ideal place for coders
new to Decko to start contributing. As _Monkeys_!

There are endless possibilities for mods, and many much-needed mods can be built
as relatively minor variations of existing mods.

In addition to the Shark invitations above, Monkeys are invited to:

 - email the [Decko Monkeys Google Group][4]
 - make [pull requests][5] to the [card-mods][6] repo.
 - join us on Slack (just request an invite in the Google Group)


## Platypuses - Weirdos Building the Platform

The rest of this document is for the more traditional audience of CONTRIBUTING files:
folks who want to help develop the code in this repository, which we often call
the _core_.

### Pull Requests
The Decko team makes heavy use of [GitHub's pull request system][5]. 
If you're not familiar with pull requests, that's the best place to start.

A great pull request is:
* small - so the team can review changes incrementally
* tested - including automatic tests that would fail without its changes
* explained - with a clear title and comments

### Development Environment

To install in a core-developer friendly mode, try `decko new mydeckname --core-dev`.  

### Testing
There are three different types of core tests. 
Unit tests are in rspec, integration/end-to-end tests exists as cucumber features and 
cypress tests.

#### Rspec
To run the whole rspec test suite execute `bundle exec decko rspec` in your
core-dev deck directory. 
If you want to run only a single spec file use 
`bundle exec decko rspec -- <path_to_spec_file>`.
For more options run `bundle exec decko rspec --help`. 

#### Cucumber
Similar to rspec run `bundle exec decko cucumber` in your deck directory.

#### Cypress
Start the server for your core-dev deck with `RAILS_ENV=cypress bundle exec decko s -p 5002`
and then in the gem in `decko/spec` run `yarn run cypress open` to open the cypress interface.
Cypress upgrades can be installed in that same directory via npm. 

#### Jasmine
Some special configuration is required for Jasmine
testing, which is currently very limited. 

See the [Jasmine README][7] for more information.

### Documentation

We use `yard`. You can run your own documentation server using:

    gem install yard
    yard server --reload

Note that each gem (card, decko, cardname, etc) has its own yard configuration (for now); 
you will need to run the server from the respective directory.

By default, the yard server will detect changes to normal ruby modules and update the
docs accordingly. But currently set modules only work if we regenerate tmpfiles after
changing code.
 
The easiest way to do that is to add something like this in 
`config/environments/development.rb`:

        Decko.application.class.configure do
          tmpsets_dir = "#{Cardio.gem_root}/tmpsets/"
          config.load_strategy = :tmp_files
          config.paths['tmp/set'] = "#{tmpsets_dir}/set"
          config.paths['tmp/set_pattern'] = "#{tmpsets_dir}/set_pattern"
        end

... and then trigger tmpset generation by loading a webpage. (The page may not load well,
because tmpfiles don't handle HAML, but all that matters is the tmpfile generation.)

[1]: https://decko.org
[2]: https://groups.google.com/g/decko-sharks
[3]: https://github.com/decko-commons/decko/issues
[4]: https://groups.google.com/g/decko-monkeys
[5]: https://help.github.com/articles/using-pull-requests
[6]: https://github.com/decko-commons/card-mods/
[7]: decko/spec/javascripts/support/README.md