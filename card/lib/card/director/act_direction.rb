class Card
  class Director
    module ActDirection
      attr_accessor :act, :act_card

      def act_director
        return unless act_card

        act_card.director
      end

      def directors
        @directors ||= {}
      end

      def run_act card
        self.act_card = card
        # add new_director(card)
        yield
      ensure
        clear
      end

      def need_act
        self.act ||= Card::Act.create ip_address: Env.ip
      end

      def clear
        self.act_card = nil
        self.act = nil
        directors.each_pair do |card, _dir|
          card.expire
          card.director = nil
          card.action = nil
          card.clear_action_specific_attributes
        end
        expire
        @directors = nil
      end

      def expire
        expirees.each { |expiree| Card.expire expiree }
        @expirees = []
      end

      def expirees
        @expirees ||= []
      end

      def fetch card, parent=nil
        return directors[card] if directors[card]

        directors.each_key do |dir_card|
          return dir_card.director if dir_card.name == card.name && dir_card.director
        end
        add new_director(card, parent)
      end

      def include? name
        directors.keys.any? { |card| card.key == name.to_name.key }
      end

      def new_director card, parent
        if !parent && act_card && act_card != card && running_act?
          act_card.director.subdirectors.add card
        else
          Director.new card, parent
        end
      end

      def card name
        directors.values.find do |dir|
          dir.card.name == name
        end&.card
      end

      def add director
        # Rails.logger.debug "added: #{director.card.name}".green
        directors[director.card] = director
      end

      def card_changed old_card
        return unless (director = @directors.delete old_card)

        add director
      end

      def delete director
        return unless @directors

        @directors.delete director.card
        director.delete
      end

      def deep_delete director
        director.subdirectors.each do |subdir|
          deep_delete subdir
        end
        delete director
      end

      def running_act?
        act_director&.running?
      end

      def to_s
        act_director.to_s
      end
    end
  end
end
