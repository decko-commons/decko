# -*- encoding : utf-8 -*-

class User < Cardio::Record
end

class UserDataToCards < Cardio::Migration::Transform
  def up
    puts "importing all user details (for those not in trash) into +*account attributes"
    User.all.each do |user|
      next unless (base = user.card_id.card)
      puts "~ importing details for #{base.name}"
      import_user_fields user, base
    end
  end

  def import_user_fields user, base
    date_args = date_args user
    %i[email salt password status].each do |field|
      cardname = [base.name, :account, field].cardname
      next unless (content = field_content field, user)

      import_user_field cardname, date_args, content
    end
  end

  def date_args user
    { created_at: user.created_at, updated_at: user.updated_at }
  end

  def field_content field, user
    user_field = (field == :password ? :crypted_password : field)
    user.send user_field
  end

  def import_user_field cardname, date_args, content
    Card.create! date_args.merge(name: cardname, content: content)
  rescue StandardError => e
    puts "error importing #{cardname}: #{e.message}"
  end
end
