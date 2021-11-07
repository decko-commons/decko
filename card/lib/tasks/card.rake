require "optparse"

namespace :card do
  desc "import card data from mod yaml"
  task in: :environment do
    options = card_options do |op|
      op.banner = "Usage: rake card:in [mark] [options]"
    end
    Cardio::Mod::InData.new(**options).merge
  end

  desc "export card data to mod yaml"
  task out: :environment do
    options = card_options do |op|
      op.banner = "Usage: rake card:out mark [options]"
    end
    Cardio::Mod::OutData.new(**options).dump
  end

  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end

  private

  def card_options
    options = {}
    op = OptionParser.new
    op.on("-m MOD", "--mod MOD") { |mod| options[:mod] = mod }
    op.on("-n NAME", "--name NAME") { |name| options[:name] = name }
    op.on("-e ENVIRONMENT", "--env ENVIRONMENT") { |env| options[:env] = env }
    yield op if block_given?
    args = op.order!(ARGV) {}
    op.parse! args
    options
  end
end
