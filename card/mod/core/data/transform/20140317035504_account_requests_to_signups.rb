# -*- encoding : utf-8 -*-

class AccountRequestsToSignups < Cardio::Migration::Transform
  def up
    newname = "Sign up"
    newname = "*signup" if Card.exists? newname

    # get old codename and name out of the way
    old_signup = Card[:signup]
    old_signup.name = "#{newname} - old"
    old_signup.codename = nil
    old_signup.save!

    # rename Account Request to "Sign up"
    new_signup = Card[:account_request]
    new_signup.name = newname
    new_signup.codename = :signup
    new_signup.save!

    # move old "*signup+*thanks" to "Sign up+*type+*thanks"
    thanks = Card[:thanks]
    if (signup_thanks = Card["#{old_signup.name}+#{thanks.name}"])
      signup_thanks.name = "#{new_signup.name}+#{Card[:type].name}+#{thanks.name}"
      signup_thanks.save!
    end

    # get rid of old signup card unless there is other data there (most likely +*subject and +*message)
    old_signup.delete! unless Card.search(return: :id, left_id: old_signup.id).first

    # turn captcha off by default on signup
    rulename = %i[signup type captcha].map { |code| Card[code].name } * "+"
    captcha_rule = Card.fetch rulename, new: {}
    captcha_rule.content = "0"
    captcha_rule.save!
  end
end
