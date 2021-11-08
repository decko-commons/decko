require "optparse"

namespace :card do
  TASK_OPTIONS = {
    m: :mod,
    n: %i[name mark],
    e: :env,
    h: :help,
    u: :url,
    i: :items,
    o: :"only-items",
    c: :cql
  }

  desc "import card data from mod yaml"
  task in: :environment do
    options = card_options do |op|
      op.banner = "Usage: rake card:in [mark] [options]"
    end
    Cardio::Mod::InData.new(**options).merge
    exit 0
  end

  desc "export card data to mod yaml"
  task out: :environment do
    options = card_options do |op|
      op.banner = "Usage: rake card:out mark [options]"
    end
    Cardio::Mod::OutData.new(**options).dump
    exit 0
  end

  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end

  

  def card_options
    options = {}
    op = OptionParser.new
    op.on("-m", "--mod MOD") { |mod| options[:mod] = mod }
    op.on("-n", "--name NAME") { |name| options[:name] = name }
    op.on("-e", "--env ENVIRONMENT") { |env| options[:env] = env }
    yield op if block_given?
    args = op.order!(ARGV) {}
    op.parse! args
    options
  end
end
