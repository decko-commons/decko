# Decko: you hold the cards

[![Gem Version][3]][4]
[![Semaphore Build][1]][2]
[![Code Climate Badge][5]][6]
[![License: GPL v3][25]][26]

- [Basics](#basics)
- [Installation](#installation)
- [Upgrading](#upgrading)
- [Mods](#mods)
- [More Resources](#more-resources)

## Basics

Decko (formerly known as "Wagn") makes serious web development fun.

Decko creators, or "Card Sharks", use Decko to create open community sites,
private knowledge management sites, public proposal submission sites with
private back-ends for review, project management systems, wikis, blogs,
journals, forums, and more.

Install Decko, open a webpage, and get started. With Decko's wiki-inspired
building blocks, you can collaborate from day one on content, design, and
structure create elegant web systems on the fly. And ruby developers can take
these creations even further with Decko's development framework. Decko's
innovative Mods API supports boundless creativity while integrating seamlessly
with structures created on the site.

Try it out!

## Installation

### 1. install dependencies

| requirement | variants |
| ---  | --- |
| [Ruby][7] | 2.5+ |
| [Bundler][8] | 1.0+ |
| [ImageMagick][9] | 6.7.8+ |
| A database engine | [MySQL][10] (5.7+) or [PostgreSQL][11] (9.4+) |
| A JavaScript runtime | [Node.js][12] (8.9+) or [other][13] |


### 2. install the gem

    gem install decko

Watch carefully for errors!

### 3. create a new deck

    decko new MY_DECK

`MY_DECK` is, of course, a variable. Use any name you like.

Options:

    -f, [--force]                            # Overwrite files that already exist
    -p, [--pretend], [--no-pretend]          # Run but do not make any changes
    -q, [--quiet], [--no-quiet]              # Suppress status output
    -s, [--skip], [--no-skip]                # Skip files that already exist
    -M, [--monkey], [--no-monkey]            # Prepare deck for monkey (mod developer)
    -P, [--platypus], [--no-core-dev]        # Prepare deck for platypus (core developer)
    -R, [--repo-path=PATH]                   # Path to local decko repository.
                                             # Can also specify via `env DECKO_REPO_PATH=PATH`
    -I, [--interactive], [--no-interactive]  # Prompt with dynamic installation options

### 4. create / seed database

Edit the config/database.yml file as necessary. More about database
configuration at https://www.decko.org/database_configuration.

Then run

    cd MY_DECK
    decko seed

..to create and seed the database

Options:

    -p, --production                 decko:seed production database (default)
    -t, --test                       decko:seed test database
    -d, --development                decko:seed development database
    -a, --all                        decko:seed production, test, and development database

### 5. start your server

To fire up the default, built-in WEBrick server, just run:

    decko server

...and point your browser to http://localhost:3000 (unless otherwise
configured).

Options:

    -p, [--port=port]                        # Runs Decko on the specified port. 
                                               Defaults to 3000.
    -b, [--binding=IP]                       # Binds Decko to the specified IP.
                                               Defaults to 'localhost' in development 
                                               and '0.0.0.0' in other environments'.
    -c, [--config=file]                      # Uses a custom rackup configuration.
                                               Default is config.ru.
    -d, [--daemon], [--no-daemon]            # Runs server as a Daemon.
    -e, [--environment=name]                 # Specifies the environment in which to run 
                                               this server (development/test/production).
    -P, [--pid=PID]                          # Specifies the PID file.
                                               Default is tmp/pids/server.pid.
        [--early-hints], [--no-early-hints]  # Enables HTTP/2 early hints.

For more information, see https://decko.org/get_started.

## Upgrading

### Standard Upgrade

#### 1. Backups
Always back up your database and uploaded files.

#### 2. Update Libraries

From your decko root directory run:

    bundle update

#### 3. Update Database

Run the following:

    decko update

#### 4. Restart your server.

### Upgrade from Wagn to Decko
If you have an old site (pre 2018), haven't upgraded in a long time, and see many 
references to "Wagn" in your deck, you may need to do a more involved update.

#### 1. update references to "wagn" in file content
In your decko's root directory, edit `Gemfile`, `config/application.rb`,
`config/routes.rb`, and `script/wagn`, replacing "wagn" with "decko". (Keep the
same capitalization pattern.)

#### 2. update references to "wagn" in file names.
From your decko root directory run:

    mv script/wagn script/decko

#### 3. continue as with Standard Upgrade
See above.

### Upgrade pre-gem Wagn site

First check the Wagn/Decko version of your existing site.

#### Version 1.10 or newer

1.  Create a new deck using steps 1 and 2 from the installation section above.
2.  Copy `config/database.yml` from the old site to the new one.
3.  Copy the old `local/files` contents to the new `files` directory.
4.  If you have edited `wagn.yml` in your old site, make the corresponding
    changes to the new `config/application.rb` file.
5.  Follow the standard upgrade procedure above.

#### Older than Version 1.10
Ho. Ly. Cow.  Welcome back!

First update your Wagn to version 1.10 via the old update mechanisms, and then
follow the directions above.

## Mods
Mods are little bits of code that alter Decko behavior.

### Installing Mods
Many mods have been made into ruby gems that follow the naming pattern `card-mod-X`. 
All you have to do to install one of these mods is:

#### 1. add the mod (or mods) to your Gemfile

     gem "card-mod-mymod"

#### 2. download and install the gem

     bundle update

#### 3. run any migrations, mergers, or scripts:

     decko update

...and then restart your server.

### Creating / Editing mods

#### Development Environment

If you're interested in making your own mod, the first thing to do is set up a good
development environment. This is most easily done by creating a new deck with the 
`--monkey` (or `-M`) options, eg:

    decko new MY_DECK --monkey
    
If you're working on an existing deck, it's often easiest just to do the above and then 
make the new deck use your existing files and database. However, if that's not an option, 
you can instead follow the following procedure:

  1. Make sure you have all the monkey-friendly gems in your Gemfile. If your deck was
     generated recently, you'll probably already have several references to these gems
     (eg card-mod-monkey) and will just need to uncomment them. If not, you can run the
     above command to create a dummy deck and copy the Gemfile over to your real one.
  2. In your real deck, comment out `ENV['RAILS_ENV'] ||= 'production'` in 
     `config/boot.rb`. This will mean your default mode is now "development."
  3. Configure `config/database.yml` to your liking.
     

#### Start Monkeying

Learn about:
 
 - [the architecture][20]
 - [how to generate a mod][19]
 - [card objects][21]
 - [formats][22]
 - [existing mods][23]

etc.

## More Resources

There's lots more info at [Decko.org][14], including:

- [Features][15]
- [Syntax Reference][16]
- [Installation Troubleshooting][17]

We also have [API Docs][18] on Swaggerhub.

And info about contributing to Decko is [right next door][24].


[1]: https://decko.semaphoreci.com/badges/decko/branches/master.svg "Semaphore Build"
[2]: https://decko.semaphoreci.com/projects/decko
[3]: https://badge.fury.io/rb/decko.svg "Gem Version"
[4]: https://badge.fury.io/rb/decko
[5]: https://api.codeclimate.com/v1/badges/6ef82d42115889ea81c7/maintainability
    "Code Climate Badge"
[6]: https://codeclimate.com/github/decko-commons/decko/maintainability
[7]: http://www.ruby-lang.org/en/
[8]: http://gembundler.com/
[9]: http://www.imagemagick.org/
[10]: http://www.mysql.com/
[11]: http://www.postgresql.org/
[12]: https://nodejs.org/
[13]: https://github.com/sstephenson/execjs
[14]: https://decko.org
[15]: https://decko.org/Features
[16]: https://decko.org/Syntax_Reference
[17]: https://decko.org/troubleshooting
[18]: https://app.swaggerhub.com/apis-docs/Decko/decko-api/0.8.0
[19]: https://github.com/decko-commons/decko/blob/master/card/lib/card/mod.rb
[20]: https://github.com/decko-commons/decko/blob/master/card/README.md
[21]: https://github.com/decko-commons/decko/blob/master/card/lib/card.rb
[22]: https://github.com/decko-commons/decko/blob/master/card/lib/card/set/format.rb
[23]: https://github.com/decko-commons/card-mods/
[24]: https://github.com/decko-commons/decko/blob/master/CONTRIBUTING.md
[25]: https://img.shields.io/badge/License-GPLv3-blue.svg
[26]: https://www.gnu.org/licenses/gpl-3.0