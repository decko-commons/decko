# -*- encoding : utf-8 -*-

class MemberIds < Cardio::Migration::Transform
  def up
    Card.search(right: :members).each &:save!
  end
end
