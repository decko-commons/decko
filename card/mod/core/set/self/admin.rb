include_set Abstract::TaskTable

basket[:tasks].merge!(
  clear_cache: {
    mod: :core,
    execute_policy: -> { Card::Cache.reset_all }
  },
  regenerate_assets: {
    mod: :core,
    execute_policy: -> { Card::Assets.refresh force: true }
  }
)

basket[:warnings] = [:no_email_delivery]
# For each warning in the basket (eg :my_warning), the core view
# will run a test by appending a question mark (eg #my_warning?).
# If it fails it will generate a message by appending message
# (eg #my_warning_message).

def no_email_delivery?
  Card.config.action_mailer.perform_deliveries == false
end

event :admin_tasks, :initialize, on: :update do
  return unless (task = Env.params[:task]&.to_sym) && (task_config = basket[:tasks][task])

  raise Card::Error::PermissionDenied, self unless Auth.always_ok?

  # when :repair_references    then Card::Reference.repair_all
  # when :repair_permissions   then Card.repair_all_permissions
  # # when :regenerate_scripts   then Card::Assets.refresh_scripts
  # when :clear_history
  #   not_allowed "clear history" unless irreversibles_tasks_allowed?
  #   Card::Action.delete_old

  run_task_from_task_basket task, task_config
  abort :success
end

def run_task_from_task_basket task, task_config
  if !irreversibles_tasks_allowed? && task_config[:irreversible]
    not_allowed t("#{task_config[:mod]}_task_#{task}_link_text")
  else
    task_config[:execute_policy]&.call
  end
end

def not_allowed task
  raise Card::Error::PermissionDenied,
        "The admin task '#{task}' is disabled for security reasons.<br>"\
        "You can enable it with the config option 'allow_irreversible_admin_tasks'"
end

def irreversibles_tasks_allowed?
  Cardio.config.allow_irreversible_admin_tasks
end

format :html do
  view :core, cache: :never do
    task_table basket[:tasks]
  end

  view :warning do
    warnings = basket[:warnings].map do |warning|
      card.send("#{warning}?") ? send("#{warning}_message") : nil
    end
    warnings.compact!
    warnings.empty? ? "" : warning_alert(warnings)
  end

  def warning_alert warnings
    # 'ADMINISTRATOR WARNING'
    alert(:warning, true) { haml :warning_alert, warnings: warnings }
  end

  def no_email_delivery_message
    # "Email delivery is turned off."
    # "Change settings in config/application.rb to send sign up notifications."
    t :core_admin_email_off, path: "config/application.rb"
  end

  # def card_stats
  #   [
  #     { title: "cards",
  #       count: Card.where(trash: false) },
  #     { title: "actions",
  #       count: Card::Action },
  #     #  link_text: "clear history",
  #     #  task: "clear_history" },
  #     { title: "references",
  #       count: Card::Reference }
  #     # link_text: "repair all",
  #     # task: "repair_references" }
  #   ]
  # end

  # def cache_stats
  #   [
  #     { title: "style assets",
  #       link_text: "regenerate styles and scripts",
  #       task: "regenerate_assets" } # ,
  #     # { title: "script assets",
  #     #   link_text: "regenerate scripts",
  #     #   task: "regenerate_scripts" }
  #   ]
  #   # return stats unless Card.config.view_cache#
  #   # stats << { title: "view cache",
  #   #            count: Card::View,
  #   #            link_text: "clear view cache",
  #   #            task: "clear_view_cache" }
  # end

  # def memory_stats
  #   oldmem = session[:memory]
  #   session[:memory] = newmem = card.profile_memory
  #   stats = [
  #     { title: "memory now",
  #       count: newmem, unit: "M",
  #       link_text: "clear cache", task: "clear_cache" }
  #   ]
  #   return stats unless oldmem
  #
  #   stats << { title: "memory prev", count: oldmem, unit: "M" }
  #   stats << { title: "memory diff", count: newmem - oldmem, unit: "M" }
  #   stats
  # end
  #
  # def stat_row args={}
  #   res = [(args[:title] || "")]
  #   res << "#{count(args[:count])}#{args[:unit]}"
  #   return res unless args[:task]
  #
  #   res << link_to_card(:admin, (args[:link_text] || args[:task]),
  #                       path: { action: :update, task: args[:task] })
  #   res
  # end
  #
  # def count counter
  #   counter = counter.call if counter.is_a?(Proc)
  #   counter.respond_to?(:count) ? counter.count : counter
  # end

  # def asset_input_cache_count
  #   Card.where(right_id: AssetInputCacheID).count
  # end
  #
  # def delete_sessions_link months
  #   link_to_card :admin, months, path: { action: :update, months: months,
  #                                        task: "delete_old_sessions" }
  # end
end

# def current_memory_usage
#   `ps -o rss= -p #{Process.pid}`.to_i
# end
#
# def profile_memory &block
#   before = current_memory_usage
#   if block_given?
#     instance_eval(&block)
#   else
#     before = 0
#   end
#   (current_memory_usage - before) / 1024.to_i
# end
