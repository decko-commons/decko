# encoding: utf-8
require 'wagn_migration_helper'

class RenamingForMenu < ActiveRecord::Migration
  include WagnMigrationHelper
  def up
    contentedly do
      renames = {
        '*content'    => '*structure',
        '*edit help'  => '*help',
        '*links'      => '*links to',
        '*inclusions' => '*includes',
        '*linkers'    => '*linked to by',
        '*includers'  => '*included by',
        '*plus cards' => '*children',
        '*plus parts' => '*mates',
        '*editing'    => '*edited',
      }
      renames.each do |oldname, newname|
        c = Card[oldname]
        c.name = newname
        c.save!
      end
      
      codenames = %w{
        by_name
        by_update
        by_create
        refers_to
        links_to
        includes
        referred_to_by
        linked_to_by
        included_by
        children
        mates
        editors
        discussion
        created
        edited
      }
      codenames.each do |codename|
        name = codename =~ /^by|disc/ ? codename : '*' + codename
        c = Card[name]
        c.codename = codename
        c.save!
      end
    end
  end

  def down
    contentedly do
      
    end
  end
end
