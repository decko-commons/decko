namespace :decko do
  namespace :migrate do
    alias_task :cards, "card:migrate:cards"
    [:cards, :structure, :core_cards, :deck_cards, :redo, :stamp].each do |task|
      alias_task task, "card:migrate:#{task}"
    end
  end
end
