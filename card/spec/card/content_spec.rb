# -*- encoding : utf-8 -*-

RSpec.describe Card::Content do
  EXAMPLES = {
    nests: {
      content: "Some Literals: \\[{I'm not| a link]}, and " \
                '\\{{This Card|Is not Nestd}}' \
                ", but " \
                "{{this is}}" \
                ", and some tail",
      rendered: ["Some Literals: \\[{I'm not| a link]}, and ",
                 "<span>{</span>{This Card|Is not Nestd}}",
                 ", but ",
                 { options: { nest_name: "this is",
                              nest_syntax: "this is" } },
                 ", and some tail"],
      classes: [String, :EscapedLiteral, String, :Nest, String]
    },

    links_and_nests: {
      content: "Some Links and includes: [[the card|the text]], " \
               "and {{This Card|Is Nestd}}{{this too}} " \
               "and [[http://external.decko.org/path|link text]]" \
               "{{Nestd|open}}",
      rendered: ["Some Links and includes: ",
                 '<a class="wanted-card" ' \
                 'href="/the_card">' \
                 '<span class="card-title" title="the text">the text</span></a>',
                 ", and ",
                 { options: { view: "Is Nestd",
                              nest_name: "This Card",
                              nest_syntax: "This Card|Is Nestd" } },
                 { options: { nest_name: "this too",
                              nest_syntax: "this too" } },
                 " and ",
                 '<a target="_blank" class="external-link" ' \
               'href="http://external.decko.org/path">link text</a>',
                 { options: { view: "open",
                              nest_name: "Nestd",
                              nest_syntax: "Nestd|open" } }],
      classes: [
        String, :Link, String, :Nest, :Nest, String, :Link, :Nest
      ]
    },

    uris_and_links: {
      content: "Some URIs and Links: http://a.url.com/ " \
               "More urls: decko.com/a/path/to.html " \
               "http://localhost:2020/path?cgi=foo&bar=baz " \
               "[[http://brain.org/Home|extra]] " \
               "[ http://gerry.decko.com/a/path ] " \
               "{ https://brain.org/more?args } ",
      rendered: ["Some URIs and Links: ",
                 '<a target="_blank" class="external-link" ' \
                 'href="http://a.url.com/">http://a.url.com/</a>',
                 " More urls: ",
                 '<a target="_blank" class="external-link" ' \
                 'href="http://decko.com/a/path/to.html">' \
                 "decko.com/a/path/to.html</a>",
                 " ",
                 '<a target="_blank" class="external-link" ' \
                 'href="http://localhost:2020/path?cgi=foo&amp;bar=baz">' \
                 "http://localhost:2020/path?cgi=foo&bar=baz</a>",
                 " ",
                 '<a target="_blank" class="external-link" ' \
                 'href="http://brain.org/Home">extra</a>',
                 " [ ",
                 '<a target="_blank" class="external-link" ' \
                 'href="http://gerry.decko.com/a/path">' \
                 "http://gerry.decko.com/a/path</a>",
                 " ] { ",
                 '<a target="_blank" class="external-link" ' \
                 'href="https://brain.org/more?args">' \
                 "https://brain.org/more?args</a>",
                 " } "],
      text_rendered: ["Some URIs and Links: ", "http://a.url.com/",
                      " More urls: ",
                      "decko.com/a/path/to.html[http://decko.com/a/path/to.html]",
                      " ",
                      "http://localhost:2020/path?cgi=foo&bar=baz",
                      " ",
                      "extra[http://brain.org/Home]",
                      " [ ",
                      "http://gerry.decko.com/a/path",
                      " ] { ",
                      "https://brain.org/more?args",
                      " } "],
      classes: [
        String, :URI, String, :HostURI, String, :URI, String, :Link,
        String, :URI, String, :URI, String
      ]
    },

    uris_and_links_2: {
      content: "Some URIs and Links: http://a.url.com " \
               "More urls: decko.com/a/path/to.html " \
               "[ http://gerry.decko.com/a/path ] " \
               "{ https://brain.org/more?args } " \
               "http://localhost:2020/path?cgi=foo&bar=baz " \
               "[[http://brain.org/Home|extra]]",
      rendered: ["Some URIs and Links: ",
                 '<a target="_blank" class="external-link" ' \
                 'href="http://a.url.com">http://a.url.com</a>',
                 " More urls: ",
                 '<a target="_blank" class="external-link" ' \
                 'href="http://decko.com/a/path/to.html">' \
                 "decko.com/a/path/to.html</a>",
                 " [ ",
                 '<a target="_blank" class="external-link" ' \
                 'href="http://gerry.decko.com/a/path">' \
                 "http://gerry.decko.com/a/path</a>",
                 " ] { ",
                 '<a target="_blank" class="external-link" ' \
                 'href="https://brain.org/more?args">' \
                 "https://brain.org/more?args</a>",
                 " } ",
                 '<a target="_blank" class="external-link" ' \
                 'href="http://localhost:2020/path?cgi=foo&amp;bar=baz">' \
                 "http://localhost:2020/path?cgi=foo&bar=baz</a>",
                 " ",
                 '<a target="_blank" class="external-link" ' \
               'href="http://brain.org/Home">extra</a>'],
      classes:  [
        String, :URI, String, :HostURI, String, :URI, String, :URI,
        String, :URI, String, :Link
      ]
    },

    no_chunks: {
      content: "No chunks",
      rendered: "No chunks"
    },

    single_nest: {
      content: "{{one nest|size;large}}",
      classes: [:Nest]
    },

    css: {
      content: %(
     /* body text */
     body {
       color: #444444;
     }

     /* page - background image and color */
     body#decko {
       background: #ffffff;
     }

     /* top bar background color; text colors */
     #menu {
       background: #3260a0;
     }
     #menu a {
       color: #EEEEEE;
     }

     /* header text */
     h1, h2 {
       color: #664444;
     }
     h1.page-header,
     h2.page-header {
       color: #222299;
     }
   )
    }
  }.freeze

  EXAMPLES.each_value do |val|
    next unless val[:classes]
    val[:classes] = val[:classes].map do |klass|
      klass.is_a?(Class) ? klass : Card::Content::Chunk.const_get(klass)
    end
  end

  context "instance" do
    before do
      @check_proc = proc do |m, v|
        if m.is_a? Array
          wrong_class = m[0] != v.class
          expect(wrong_class).to be_falsey
          is_last = m.size == 1
          is_last ? true : m[1..-1] unless wrong_class
        end
      end

      assert card = Card["One"]
      @card = card

      # non-nil valued opts only ...
      @render_block = proc do |chunk|
        if chunk.is_a?(described_class::Chunk::Nest)
          options = chunk.options.inject({}) do |i, v|
            i if !v[1].nil? && (i[v[0]] = v[1])
          end
          { options: options }
        else
          chunk.process_chunk
        end
      end
    end

    let(:example)       { EXAMPLES[@example] }
    let(:cobj)          { Card::Content.new example[:content], @card }
    let(:classes)       { example[:classes] }
    let(:rendered)      { example[:rendered] }
    let(:text_rendered) { example[:text_rendered] }
    let(:content)       { example[:content] }

    describe "parse" do
      def check_chunk_classes
        all_classes_pass_check_proc
        clist = nonstring_classes
        cobj.each_chunk do |chk|
          expect(chk).to be_instance_of clist.shift
        end
        expect(clist).to be_empty
      end

      def nonstring_classes
        classes.select { |c| String != c }
      end

      def all_classes_pass_check_proc
        expect(cobj.inject(classes, &@check_proc)).to eq(true)
      end

      it "finds all the chunks and strings" do
        # note the mixed [} that are considered matching, needs some cleanup ...
        @example = :nests
        all_classes_pass_check_proc
      end

      it "gives just the chunks" do
        @example = :nests
        check_chunk_classes
      end

      it "finds all the chunks links and trasclusions" do
        @example = :links_and_nests
        all_classes_pass_check_proc
      end

      it "finds uri chunks " do
        # tried some tougher cases that failed, don't know the spec, so
        # hard to form better tests for URIs here
        @example = :uris_and_links
        check_chunk_classes
      end

      it "finds uri chunks (b)" do
        # tried some tougher cases that failed, don't know the spec, so
        # hard to form better tests for URIs here
        @example = :uris_and_links_2
        check_chunk_classes
      end

      it "parses just a string" do
        @example = :no_chunks
        expect(cobj).to eq(rendered)
      end

      it "parses a single chunk" do
        @example = :single_nest
        check_chunk_classes
      end

      it "leaves css alone" do
        @example = :css
        expect(cobj).to eq(content)
      end
    end

    describe "render" do
      it "renders all nests" do
        @example = :nests
        expect(cobj.as_json.to_s).to match(/not rendered/)
        cobj.process_chunks(&@render_block)
        rdr = cobj.as_json.to_json
        expect(rdr).not_to match(/not rendered/)
        expect(rdr).to eq(rendered.to_json)
      end

      it "renders links and nests" do
        @example = :links_and_nests
        expect(cobj.as_json.to_s).to match(/not rendered/)
        cobj.process_chunks(&@render_block)
        rdr = cobj.as_json.to_json
        expect(rdr).not_to match(/not rendered/)
        expect(rdr).to eq(rendered.to_json)
      end

      it "renders links correctly for text formatters" do
        @example = :uris_and_links
        card2 = Card[@card.id]
        format = card2.format format: :text
        cobj = Card::Content.new content, format
        cobj.process_chunks
        expect(cobj.as_json.to_json).to eq(text_rendered.to_json)
      end

      it "does not need rendering if no nests" do
        @example = :uris_and_links
        cobj.process_chunks
        expect(cobj.as_json.to_json).to eq(rendered.to_json)
      end

      it "does not need rendering if no nests (b)" do
        @example = :uris_and_links_2
        rdr1 = cobj.as_json.to_json
        expect(rdr1).to match(/not rendered/)
        # links are rendered too, but not with a block
        cobj.process_chunks
        rdr2 = cobj.as_json.to_json
        expect(rdr2).not_to match(/not rendered/)
        expect(rdr2).to eq(rendered.to_json)
      end
    end
  end

  UNTAGGED_CASES = [" [grrew][/wiki/grrew]ss ",
                    " {{this is a test}}, {{this|view|is:too}} and",
                    " so is http://foo.bar.come//",
                    ' and foo="my attr, not int a tag" <not a=tag ',
                    ' p class"foobar"> and more'].freeze

  context "class" do
    describe "#clean!" do
      it "does not alter untagged content" do
        UNTAGGED_CASES.each do |test_case|
          assert_equal test_case, Card::Content.clean!(test_case)
        end
      end

      it "strips disallowed html class attributes" do
        assert_equal "<p>html<div>with</div> funky tags</p>",
                     Card::Content.clean!(
                       '<p>html<div class="boo">with</div>' \
                       "<monkey>funky</butts>tags</p>"
                     )
        assert_equal "<span>foo</span>",
                     Card::Content.clean!('<span class="banana">foo</span>')
      end

      it "does not strip permitted_classes" do
        has_stripped1 = '<span class="w-spotlight">foo</span>'
        assert_equal has_stripped1,
                     Card::Content.clean!(has_stripped1)
        has_stripped2 = '<p class="w-highlight w-ok">foo</p>'
        assert_equal has_stripped2,
                     Card::Content.clean!(has_stripped2)
      end

      it "strips permitted_classes " \
            "but not permitted ones when both are present" do
        assert_equal '<span class="w-spotlight w-ok">foo</span>',
                     Card::Content.clean!(
                       '<span class="w-spotlight banana w-ok">foo</span>'
                     )
        assert_equal '<p class="w-highlight">foo</p>',
                     Card::Content.clean!(
                       '<p class="w-highlight bad-at end">foo</p>'
                     )
        assert_equal '<p class="w-highlight">foo</p>',
                     Card::Content.clean!(
                       '<p class="bad-class w-highlight">foo</p>'
                     )
      end

      it "allows permitted attributes" do
        assert_equal '<img src="foo">', Card::Content.clean!('<img src="foo">')
        assert_equal "<img alt='foo'>", Card::Content.clean!("<img alt='foo'>")
        assert_equal '<img title="foo">', Card::Content.clean!("<img title=foo>")
        assert_equal '<a href="foo">', Card::Content.clean!('<a href="foo">')
        assert_equal '<code lang="foo">', Card::Content.clean!('<code lang="foo">')
        assert_equal '<blockquote cite="foo">',
                     Card::Content.clean!('<blockquote cite="foo">')
      end

      it "does not allow nonpermitted attributes" do
        assert_equal "<img>", Card::Content.clean!('<img size="25">')
        assert_equal "<p>",   Card::Content.clean!('<p font="blah">')
      end

      it "removes comments" do
        assert_equal "yo", Card::Content.clean!("<!-- not me -->yo")
        assert_equal "joe",
                     Card::Content.clean!("<!-- not me -->joe<!-- not me -->")
      end

      it "fixes regular nbsp order by default" do
        assert_equal "space&nbsp; test&nbsp; two&nbsp;&nbsp; space",
                     Card::Content.clean!(
                       "space&nbsp; test &nbsp;two &nbsp;&nbsp;space"
                     )
      end

      # it "doesn't fix regular nbsp order with setting" do
      #   # manually configure this setting, then make this one live
      #   # (test above will then fail)
      #   pending "Can't set Cardio.config.space_last_in_multispace= false "\
      #           'for one test'
      #   assert_equal 'space&nbsp; test &nbsp;two &nbsp;&nbsp;space',
      #                Card::Content.clean!(
      #                  'space&nbsp; test &nbsp;two &nbsp;&nbsp;space'
      #                )
      # end
    end
  end

  describe "#pieces" do
    def pieces content
      Card::Content.new(content, Card["A"],).pieces
    end

    example "A {{B}}" do
      expect(pieces("A {{B}}").size).to eq 2
    end

    example "A" do
      expect(pieces("A").size).to eq 1
    end

    example "{{B}}" do
      expect(pieces("{{B}}").size).to eq 1
    end
  end
end
