# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::ScriptJqueryHelper do
  subject { Card[:script_jquery_helper].content }

  it "loads jquery-ui v1.12.1" do
    # We use jquery-ui with selectable and autocomplete included.
    # All other additional stuff in jquery-ui is there because those two
    # depend on it.
    is_expected.to include "jQuery UI - v1.12.1"
  end

  it "loads jquery.autosize" do
    # We call "autosize" for the ace editor in script_ace_config.js.coffee
    # when no ace mode is set.
    # No idea how important that is -pk
    is_expected.to include "Autosize 1.18.13"
  end

  it "loads jquery.fileupload" do
    # used for upload form of file and image cards
    is_expected.to include "jQuery File Upload Plugin"
  end

  it "loads jquery.iframe-transport" do
    # Used to be there and is part of the jquery.fileupload gem.
    # No idea if we depend on it -pk
    is_expected.to include "jQuery Iframe Transport Plugin"
  end
end
