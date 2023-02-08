<!--
# @title README - mod: assets
-->
# Assets mod

This mod unifies handling of styles (CSS, SCSS, etc) and scripts 
(JavaScript, CoffeeScript, etc).

For both, the idea is to output optimized files that will support browser caching
and thus improve users' experience by reducing loading times. In other words, we use
a wide variety of asset sources to assemble a ready-for-prime-time outputs.

There are two main kinds of cards in the asset pipeline: inputters (where
the code comes from) and outputters (where it ends up).

## Inputters

Inputters can be created in multiple ways:

1. By adding code to the assets directory in a mod
2. By adding remote and/or local assets to a manifest.yml file
3. By combining other inputters
4. By directly creating cards of an inputter type

### adding code to the assets directory

Each mod can have an `assets` directory with `style` and `script` subdirectories. 
By adding CSS or SCSS files to `assets/style` (or JavaScript or CoffeeScript
files to `assets/script`) to a mod in use, your code will automatically be included
in standard asset output. 

After adding the first asset to a mod, you may need to run `rake card:mod:install` (or
the more comprehensive `decko update`) for the change to take effect.

By default, the load order within a mod is alphabetical, and the load order across mods
is governed by the mod load order, which can be seen using `rake card:mod:list`.

### using manifest.yml files

If you want to customize the load order of asset files, you can add a `manifest.yml` 
file to `assets/style` or `assets/script`. 

For example, consider these lines from the manifest.yml file in the bootstrap mod:

```
libraries:
  items:
    - font_awesome.css
    - material_icons.css
    - bootstrap_colorpicker.scss
    - ../../vendor/bootstrap-colorpicker/src/sass/_colorpicker.scss
```

The word `libraries` is an arbitrary name for the manifest group; you can use any name
(other than `remote`) as long as it isn't duplicated in the file.  The `items` specify 
the load order for this manifest group.

Note that the manifest also makes it possible to include source files that are not in
the assets directory using relative path references.

Manifests also make it possible to include remote files. For example:

```
remote:
  items:
    - src: https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.1/js/select2.full.min.js
      integrity: ...
      referrerpolicy: no-referrer
      crossorigin: anonymous
```

### combining other inputters

There are various special cards that combine inputters and are inputters themselves:

  - the :style_mods card contains all the standard assets from mods' asset directories
  - skin cards combine a particular set of styles
  - (Mod)+:style and (Mod)+:script assemble the assets for a given mod

### creating inputter cards

Many Cardtypes are coded to be inputters. If you create a card with the type CSS,
for example, it will automatically be treated as an inputter. The same goes for SCSS,
CoffeeScript, and JavaScript cards. (In code terms, this is achieved by having those
sets include the `Abstract::AssetInputter` set).

Because these cards are intended for Sharks, they are predominantly documented on
decko.org

## Outputters

Outputters produce the final asset (.js and .css) files delivered to users' browsers.

They work slightly differently with style and script cards. JavaScript (.js) output is 
produced on a mod-by-mod basis. The `:all+:script` rule maintains a list of all mods
with script inputters, and output is produced for each mod that assembles all the 
javascript for that mod. The output is managed with a file card using the name pattern
`MOD+:asset_ouput`

With style cards, SCSS variables are often shared across many mods, so the output CSS 
cannot be constructed on a mod-by-mod basis; it has to be generated across all mods at 
once. Thus the site's main CSS is served as a single file associated with `:all+:style`,
which typically points to a skin card.  The output is managed as a file card at 
`:all+:style+:asset_output`.


### generating output from input

For each inputter, we generate a VirtualCache card following this pattern: 
`(Inputter)+:asset_input`. This card processes the inputs as much as it safely can.
For example, SCSS cards cannot be converted to CSS here, because they often 
involve variables that must be used by other inputters. 

When changes to inputters are detected, they trigger changes to all inputters and 
outputters that depend on them.

