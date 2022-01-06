# -*- encoding : utf-8 -*-

class User < Cardio::Record
end

class UserDataToCards < Cardio::Migration::Core
  def up
    puts "adding new codename cards"
    %i[password token salt status signin stats].each do |codename|
      Card.create! name: "*#{codename}", codename: codename
    end

    puts "setting read permissions for account cards (Administrator)"
    %i[password token salt status email account].each do |codename|
      rule_name = [codename, :right, :read].map { |code| Card[code].name } * "+"
      rule_card = Card.fetch rule_name, new: {}
      rule_card.content = "[[Administrator]]"
      rule_card.save!
    end

    puts "making email and password fields default to Phrase cards"
    %i[email password].each do |field|
      rulename = [field, :right, :default].map { |code| Card[code].name } * "+"
      Card.create! name: rulename, type_id: Card::PhraseID
    end

    puts "signin permissions"
    %i[read update].each do |setting|
      rulename = [:signin, :self, setting].map { |code| Card[code].name } * "+"
      Card.create! name: rulename, content: "[[#{Card[:anyone].name}]]"
    end

    puts "supporting legacy handling of +*email on User cards"
    oldname = %i[email right structure].map { |code| Card[code].name } * "+"
    newname = %i[user email type_plus_right structure].map do |code|
      Card[code].name
    end * "+"
    Card[oldname].update! name: newname

    puts "importing all user details (for those not in trash) into +*account attributes"
    User.all.each do |user|
      base = Card[user.card_id]
      next unless base && !base.trash

      puts "~ importing details for #{base.name}"
      date_args = { created_at: user.created_at, updated_at: user.updated_at }
      %i[email salt password status].each do |field|
        cardname = "#{base.name}+#{Card[:account].name}+#{Card[field].name}"
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

# FIXME
# before 1.13!
# but add read permission migration for *stats and
# structure for *stats+*right
