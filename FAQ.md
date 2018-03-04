# FAQ

1. **How can I use my local decko instead of the installed `decko` gem so that I can modify the decko?**

   ```
   $ decko new <Deck Name> --core-dev
   ```

   This command will then ask for the local decko path. The created deck will be using your local `decko` folder as the gem path in the `GemFile`.

1. **While I started a decko server with the local decko path, it showed the error of `NoMethodError (undefined method 'notable_exception_raised' for #<Card:0x007f8d44fed250>):`.**

   After cloning the decko code from github, there are serval submodules that need to be initialized. You may run the command `git submodule update --init --recursive` in your local decko root directory. Then redo the seeding `bundle exec decko seed`.

1. **I have a problem to upload image to my site. The image uploaded is shown as zero bytes with a broken image in the preview but uploading a non-image is fine.**

   Your environment is missing the package `ImageMagick`.
   Mac OS:
   `brew install imagemagick`
   Ubuntu:
   `sudo apt-get install imagemagick`
