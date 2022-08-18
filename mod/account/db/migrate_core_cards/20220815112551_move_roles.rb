# -*- encoding : utf-8 -*-

require 'pry'

class  MoveRoles < Cardio::Migration
  def up
    Card.search(left: { type_id: Card::RoleID }, right_id: Card::MembersID) do |role_members|
      role_members.update! type_id: Card::ListID
    end

    Card.search(left: { type_id: Card::UserID }, right_id: Card::RolesID ) do |user_roles|
      content = ActiveRecord::Base.connection.exec_query("SELECT db_content FROM cards WHERE cards.id = #{user_roles.id}").rows&.first&.first
      next unless content.present?

      role_names = content.split "\n"
      role_names.each do |role_name|
        puts "Move #{user_roles.left_name} to role #{role_name}"
        Card[role_name, :members].add_item! role_name
      end
      user_roles.delete
    end
  end
end
