# -*- encoding : utf-8 -*-

class User < Cardio::Record
end

class UserDataToCards < Cardio::Migration::TransformMigration
  def up
    puts "importing all user details (for those not in trash) into +*account attributes"
    User.all.each do |user|
      base = Card[user.card_id]
      next unless base && !base.trash

      puts "~ importing details for #{base.name}"
      date_args = { created_at: user.created_at, updated_at: user.updated_at }
      %i[email salt password status].each do |field|
        cardname = [base.name, :account, field].cardname
        user_field = (field == :password ? :crypted_password : field)
        next unless (content = user.send(user_field))

        begin
          Card.create! date_args.merge(name: cardname, content: content)
        rescue StandardError => e
          puts "error importing #{cardname}: #{e.message}"
        end
      end
    end
  end
end
