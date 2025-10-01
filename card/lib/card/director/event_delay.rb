class Card
  class Director
    # methods for handling delayed events
    module EventDelay
      # If active jobs (and hence the integrate_with_delay events) don't run
      # in a background process then Card::Env.deserialize! decouples the
      # controller's params hash and the Card::Env's params hash with the
      # effect that params changes in the CardController get lost
      # (a crucial example are success params that are processed in
      # CardController#soft_redirect)
      def contextualize_delayed_event act_id, card, env, auth, &block
        return yield unless delaying?

        with_env_and_auth env, auth do
          with_delay_act(act_id, card, &block)
        end
      end

      def delaying?
        Cardio.config.delaying == true
      end

      def with_delay_act(act_id, card, &)
        return yield unless act_id && (self.act = Act.find act_id)

        run_job_with_act(act, card, &)
      end

      def run_job_with_act act, card, &block
        run_act card do
          act_card.director.run_delayed_event act, &block
        end
      end

      def with_env_and_auth env, auth, &block
        Card::Auth.with auth do
          Card::Env.with env, &block
        end
      end
    end
  end
end
