# -*- encoding : utf-8 -*-

class RenamingForMenu < Cardio::Migration::Transform
  OLDNAMES = %w[
    *links,
    *inclusions,
    *linkers
    *includers
    *plus cards
    *plus parts
    *editing
  ].freeze

  def up
    OLDNAMES.each { |oldname| oldname.card&.delete! }
  end
end
