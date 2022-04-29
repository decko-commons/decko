require "colorize"
require "benchmark"

namespace :decko do
  namespace :benchmark do
    desc "(for platypuses) measure time for script generation"
    task machines: :environment do
      Benchmark.bm do |x|
        regenerate x, :style
        regenerate x, :script
      end
    end
  end
end

def regenerate benchmarker, all_field
  Card::Auth.as_bot do
    card = Card[:all, all_field]
    Card::Machine.reset_all

    card.machine_input_card.extended_item_cards.each do |i_card|
      puts i_card
      i_card.expire_machine_cache
    end

    Card::Cache.reset_all

    benchmarker.report(all_field) do
      card.update_machine_output
      # regenerate_machine_output
    end
    # puts Card[:all,  all_field, :machine_output].attachment.read
  end
end
