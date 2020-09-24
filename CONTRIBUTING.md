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
mod lists, and deck configuration** – on [Decko.org](https://decko.org).


## Monkeys - Makers of Mods
Mods (short for modules, modifications, modicum, whatever...) are the main 
mechanism for extending Decko behavior, and they're the ideal place for coders
new to Decko to start contributing. As _Monkeys_!


Documentation is still sparse, but you can get a sense for how to start by reading
lib/card/set.rb.

To install in a mod-developer friendly mode, try `decko new mydeckname --mod-dev` 
(still uses standard gem installation).

## Platypuses - Weirdos Building the Platform


### Pull Requests
The Decko team makes heavy use of
[GitHub's pull request system](https://help.github.com/articles/using-pull-requests). 
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
If you want to run only a single spec file use `bundle exec decko rspec -- <path_to_spec_file>`.
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

See decko/spec/javascripts/support/README.md for more information.

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
