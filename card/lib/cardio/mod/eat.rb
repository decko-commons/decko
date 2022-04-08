require "timecop"
# require "pry"

DATA_ENVIRONMENTS = %i[production development test].freeze
ENV["STORE_CODED_FILES"] = "true"

module Cardio
  class Mod
    # import data from data directory of mods
    # (list of card attributes)
    # https://docs.google.com/document/d/13K_ynFwfpHwc3t5gnLeAkZJZHco1wK063nJNYwU8qfc/edit#
    class Eat
      include Card::Model::SaveHelper
      include Edibles

      def initialize mod: nil, env: nil, user: nil, verbose: nil
        @mod = mod
        @env = "test" # env
        @user_id = user&.card_id
        @verbose = true # !verbose.nil?
      end

      def up
        Card::Cache.reset_all
        Card::Mailer.perform_deliveries = false
        Card::Auth.as_bot do
          edibles.each do |edible|
            track edible do
              current_user edible.delete(:user)
              time_machine edible.delete(:time) do
                ensure_card edible
              end
            end
          end
        end
      end

      private

      def track edible
        rescuing edible do
          # puts "eating: #{edible}" if @verbose
          card = yield
          puts "eaten: #{card.name}".green if @verbose
        end
      end

      def rescuing edible
        yield
      rescue StandardError => e
        puts edible
        puts e.message.red
        puts e.backtrace[0..10].join("\n") if @verbose
      end

      def current_user item_user
        Card::Auth.current_id = item_user&.card_id || @user_id || Card::WagnBotID
      end

      def time_machine value, &block
        return yield unless value.present?

        Timecop.freeze Time.at(time_integer(value)), &block
      end

      def time_integer value
        case value
        when /^[+-]\d+$/
          # plus or minus an integer (safe to eval)
          eval "#{Time.now.to_i} #{value}", binding, __FILE__, __LINE__
        when Integer
          value
        else
          raise TypeError, "invalid time value: #{value}. accepts int, +int, and -int"
        end
      end
    end
  end
end
