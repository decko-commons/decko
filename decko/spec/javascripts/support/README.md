#### Configuration

This directory contains our main jasmine configuration file: one main
 configuration file: `jasmine.yml`. The yml can only be read with our modified 
`jasmine-rails` [gem](https://github.com/chuenlok/jasmine-rails), because we
need to parse it as ERB before loading as a normal yml. Decko path cannot be
hard coded to use this configuration file, so we need `Jasmine-Rails` to 
parse `Decko.gem_root` when reading the yml file.

#### Explanation
Most of the things are same with default settings. However, the `src_dir` 
and `css_dir` are not working as they are pointed to `app/assets` folder which 
is the default path of the asset pipeline. The important setting is 
`include_dir`. This will inlcude things outside app folder into the asset 
pipeline. That means, things inside Decko gem and folder `mod` can be included in
this way.

For core testing, the default settings now will include the js and coffee inside
`mod/machines/lib/javascript`. For mod development, the default settings now 
will include the js and coffee inside `mod`.


#### How to run
1. just like the way to create a deck to test core or mod-dev
2. configure the `spec/javascripts/support/jasmine.yml` if necessary
3. `bundle exec decko jm`