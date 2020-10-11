namespace :card do
  namespace :grab do
    desc "add card to import data"
    task pull: :environment do
      pull_card
    end

    desc "add card and all nested cards to import data"
    task deep_pull: :environment do
      pull_card deep: true
    end

    desc "add nested cards to import data (not the card itself)"
    task deep_pull_items: :environment do
      pull_card items_only: true
    end

    # be rake card:pull_export from=live
    desc "add items of the export card to import data"
    task pull_export: :environment do
      importer.pull "export", items_only: true, remote: ENV["from"]
    end

    def pull_card opts={}
      _task, card = ARGV
      raise "no card given" unless card.present?

      importer.pull card, opts.merge(remote: ENV["from"])
      exit # without exit the card argument is treated as second rake task
    end
  end
end

