class Card
  class Act
    class ActRenderer
      # Used for the bridge
      class RelativeLinkActRenderer < RelativeActRenderer
        def title
          ["##{@args[:act_seq]}", @act.actor.name, wrap_with(:small, edited_ago)].join " "
        end
      end
    end
  end
end
