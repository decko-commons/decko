# Thinking about contributing to Decko?
Welcome! And thanks for taking the first step.

We want to make contributing to Decko as rewarding an experience as possible. Please jump in, and ask away for help.

FIXME: contact routes here (support ticket, google group, etc.  slack?)

## Basics
The Decko team makes heavy use of [GitHub's pull request system](https://help.github.com/articles/using-pull-requests).  If you're not familiar with pull requests, that's the best place to start.

A great pull request is:
* small - so the team can review changes incrementally
* tested - including automatic tests that would fail without its changes
* explained - with a clear title and comments

## Developing Mods
Mods (short for modules, modifications, modicums, modesty, whatever...) are the main mechanism for extending Decko behaviors, and they're a great place to start learning how to contribute.

Documentation is still sparse, but you can get a sense for how to start by reading lib/card/set.rb.

To install in a mod-developer friendly mode, try `decko new mydeckname --mod-dev` (still uses standard gem installation).

## Developing the Core

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




### Troubleshooting

#### While I started a decko server with the local decko path, it showed the error of `NoMethodError (undefined method 'notable_exception_raised' for #<Card:0x007f8d44fed250>):`.

After cloning the decko code from github, there are several submodules that need to be initialized. You may run the command `git submodule update --init --recursive` in your local decko root directory. Then redo the seeding `bundle exec decko seed`.

#### I have a problem to upload image to my site. The image uploaded is shown as zero bytes with a broken image in the preview but uploading a non-image is fine.

Your environment is missing the package `ImageMagick`.

Mac OS:

`brew install imagemagick`

Ubuntu:

`sudo apt-get install imagemagick`

### Documentation

We use `yard`.  

For the basics, you can use:

    gem install yard
    yard server --reload

But for set modules to work, you will need to regenerate tmpfiles after you change code.
The easiest way to do that is to add something like this in 
`config/environments/development.rb`:

        Decko.application.class.configure do
          tmpsets_dir = "#{Cardio.gem_root}/tmpsets/"
          config.load_strategy = :tmp_files
          config.paths['tmp/set'] = "#{tmpsets_dir}/set"
          config.paths['tmp/set_pattern'] = "#{tmpsets_dir}/set_pattern"
        end

... and then trigger tmpset generation by loading a webpage. (Even though webpages that
use HAML templates will break.)

Note that decko and card have separate configurations; you will need to run the server
from the respective directories.

