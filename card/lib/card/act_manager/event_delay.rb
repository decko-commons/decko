class Card
  class ActManager
    # methods for handling delayed events
    module EventDelay
      # If active jobs (and hence the integrate_with_delay events) don't run
      # in a background process then Card::Env.deserialize! decouples the
      # controller's params hash and the Card::Env's params hash with the
      # effect that params changes in the CardController get lost
      # (a crucial example are success params that are processed in
      # CardController#soft_redirect)
      def contextualize_delayed_event act_id, card, env, auth
        if delaying?
          contextualize_for_delay(act_id, card, env, auth) { yield }
        else
          yield
        end
      end

      def delaying?
        const_defined?("Delayed") &&
          Delayed::Worker.delay_jobs &&
          Card.config.active_job.queue_adapter == :delayed_job
      end

      # The whole ActManager setup is gone once we reach a integrate with delay
      # event processed by ActiveJob.
      # This is the improvised resetup to get subcards working.
      def contextualize_for_delay act_id, card, env, auth, &block
        self.act = Act.find act_id if act_id
        with_env_and_auth env, auth do
          return yield unless act

          run_act(act.card || card) do
            act_card.director.run_delayed_event act, &block
          end
        end
      end

      def with_env_and_auth env, auth
        Card::Auth.with auth do
          Card::Env.with env do
            yield
          end
        end
      end
    end
  end
end