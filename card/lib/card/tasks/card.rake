require "rake"

# This code lets us redefine existing Rake tasks, which is extremely
# handy for modifying existing Rails rake tasks.
# Credit for the original snippet of code goes to Jeremy Kemper
# http://pastie.caboo.se/9620
unless Rake::TaskManager.methods.include?(:redefine_task)
  module Rake
    module TaskManager
      def redefine_task task_class, args, &block
        task_name, arg_names, deps = resolve_args(args)
        task_name = task_class.scope_name(@scope, task_name)
        deps = [deps] unless deps.respond_to?(:to_ary)
        deps = deps.map(&:to_s)
        task = @tasks[task_name.to_s] = task_class.new(task_name, self)
        task.application = self
        @last_comment = nil
        task.enhance(deps, &block)
        task
      end
    end
    class Task
      class << self
        def redefine_task args, &block
          Rake.application.redefine_task(self, [args], &block)
        end
      end
    end
  end
end

namespace :card do
  def importer
    @importer ||= Card::Migration::Import.new Card::Migration.data_path
  end

  desc "add a new card to import data"
  task add: :environment do
    _task, name, type, codename = ARGV
    importer.add_card name: name, type: type || "Basic", codename: codename
    exit
  end

  desc "register remote for importing card data"
  task add_remote: :environment do
    _task, name, url = ARGV
    raise "no name given" unless name.present?
    raise "no url given" unless url.present?

    importer.add_remote name, url
    exit
  end

  desc "migrate structure and cards"
  task migrate: :environment do
    ENV["NO_RAILS_CACHE"] = "true"
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"

    stamp = ENV["STAMP_MIGRATIONS"]

    puts "migrating structure"
    Rake::Task["card:migrate:structure"].invoke
    Rake::Task["card:migrate:stamp"].invoke :structure if stamp

    puts "migrating core cards"
    Card::Cache.reset_all
    # not invoke because we don't want to reload environment
    Rake::Task["card:migrate:core_cards"].execute
    if stamp
      Rake::Task["card:migrate:stamp"].reenable
      Rake::Task["card:migrate:stamp"].invoke :core_cards
    end

    puts "migrating deck structure"
    Rake::Task["card:migrate:deck_structure"].execute
    if stamp
      Rake::Task["card:migrate:stamp"].reenable
      Rake::Task["card:migrate:stamp"].invoke :core_cards
    end

    puts "migrating deck cards"
    # not invoke because we don't want to reload environment
    Rake::Task["card:migrate:deck_cards"].execute
    if stamp
      Rake::Task["card:migrate:stamp"].reenable
      Rake::Task["card:migrate:stamp"].invoke :deck_cards
    end

    Card::Cache.reset_all
  end
end
