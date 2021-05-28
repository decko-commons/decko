module Cardio
  module Pry
    # Pry command configuration
    module Commands
      class << self
        def alias_command *args
          ::Pry.config.commands.alias_command(*args)
        end

        def block_command *args
          ::Pry.commands.block_command(*args)
        end
      end

      ::Pry.config.editor = proc { |file, line| "mine #{file}:#{line}" }

      alias_command "h", "hist -T 20", desc: "Last 20 commands"
      alias_command "hg", "hist -T 20 -G", desc: "Up to 20 commands matching expression"
      alias_command "hG", "hist -G", desc: "Commands matching expression ever used"
      alias_command "hr", "hist -r", desc: "hist -r <command number> to run a command"
      alias_command "clear", "break --delete-all", desc: "remove all break points"

      # Hit Enter to repeat last command
      ::Pry::Commands.command(/^$/, "repeat last command") do
        pry_instance.run_command ::Pry.history.to_a.last
      end

      if defined?(PryByebug)
        ::Pry.commands.alias_command "c", "continue"
        ::Pry.commands.alias_command "s", "step"
        ::Pry.commands.alias_command "n", "next"
        ::Pry.commands.alias_command "f", "finish"
      end

      # breakpoint commands
      block_command "try", "play expression in current line" do |offset|
        line = target.eval("__LINE__")
        line = line.to_i + offset.to_i if offset
        run "play -e #{line}"
      end

      block_command "breakview",
                    "set break point where view is rendered" do |view_name, cardish|
        breakpoint = "break #{Cardio.gem_root}/lib/card/format/render.rb:43"

        breakpoint += " if view.to_sym == \\'#{view_name}\\'.to_sym" if view_name
        breakpoint += " && card.key == \\'#{cardish}\\'.to_name.key" if cardish
        run breakpoint
      end

      block_command "breaknest", "set break point where nest is rendered" do |card_key|
        breakpoint = "break #{Cardio.gem_root}/lib/card/format/nest.rb:19"
        if card_key
          breakpoint += " if cardish.to_name.key == \\'#{card_key}\\'.to_name.key"
        end
        run breakpoint
      end

      alias_command "bv", "breakview"
      alias_command "bn", "breaknest"
    end
  end
end
