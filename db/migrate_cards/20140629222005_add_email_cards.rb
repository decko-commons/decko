# -*- encoding : utf-8 -*-

class AddEmailCards < Wagn::Migration
  def up
    # create new cardtype for email templates
    Card.create! :name=>"Email template", :codename=>:email_template, :type_id=>Card::CardtypeID
    Card.create! :name=>"Email template+*type+*structure", 
        :content=>"{{+*from|titled}}\n{{+*to|titled}}\n{{+*cc|titled}}\n{{+*bcc|titled}}\n{{+*subject|titled}}\n{{+*html message|titled}}\n{{+*text message|titled}}\n{{+*attach|titled}}"
    
    c = Card.fetch '*message', :new=>{ }
    c.name     = '*html message'
    c.codename =  'html_message'
    c.save!
    
    Card.create! :name=>'*text message', :codename=>'text_message'
    Card.create! :name=>"*text message+*right+*default", :type_code=>:plain_text
    
    if email_config=Card.fetch("email_config+*right+*structure")
      email_config.update_attributes( 
        :content=>"{{+*from|titled}}\n{{+*to|titled}}\n{{+*cc|titled}}\n{{+*bcc|titled}}\n{{+*subject|titled}}\n{{+*html message|titled}}\n{{+*text message|titled}}\n{{+*attach|titled}}"
      )
    end
    Wagn::Cache.reset_global
    # create system email cards
    dir = "#{Wagn.gem_root}/db/migrate_cards/data/mailer"
    json = File.read( File.join( dir, 'mail_config.json' ))
    data = JSON.parse(json)
    data.each do |mail|
      mail = mail.symbolize_keys!
      Card.create! :name=> mail[:name], :codename=>mail[:codename], :type_id=>Card::EmailTemplateID
      Card.create! :name=>"#{mail[:name]}+*html message", :content=>File.read( File.join( dir, "#{mail[:codename]}.html" ))
      Card.create! :name=>"#{mail[:name]}+*text message", :content=>File.read( File.join( dir, "#{mail[:codename]}.txt" ))
      Card.create! :name=>"#{mail[:name]}+*subject", :content=>mail[:subject] 
    end
    
    # change notification rules
    %w( create update delete ).each do |action|
      Card.create! :name => "*on #{action}", :type_code=>:setting, :codename=>"on_#{action}"
      Card.create! :name => "*on #{action}+*right+*help", :content=>"Configures email to be sent when card is #{action}d."
      Card.create! :name => "*on #{action}+*right+*default", :type_code=>:pointer, 
                   :content=>"[[_left+email config]]"
    end
    
    # move old send rule to on_create
    fields = %w( to from cc bcc subject message attach )
    Card.search(:right=>"*send").each do |send_rule|
      Card.create! :name=>"send_rule.left+*on create", :content=>send_rule.content, :type_code=>:pointer
      send_rule.delete  #@ethn: keep old rule for safety reasons?
    end
  
    # the new watch rule
    Card.create! :name => '*following', :type_code=>:pointer, :codename=>'following'
    Card.create! :name => '*following+*right+*default', :type_code=>:pointer
    Card.create! :name => '*following+*right+*update', :content=>'_left'
    Card.create! :name => '*following+*right+*create', :content=>'_left'
    Card::Codename.reset_cache      
    
    # move old watch rules
    # +watchers
    follower_hash = Hash.new { |h, v| h[v] = [] } 

    Card.search(:right_plus => {:codename=> "watchers"}).each do |card|
      if watched = card.left
        card.item_names.each do |user_name|
          follower_hash[user_name] << watched.name
        end
      end
    end
    
    follower_hash.each do |user, items|
      if card=Card.fetch(user) and card.account
        following = card.fetch :trait=>"following", :new=>{}
        following.items = items
      end
    end
    
    if watchers = Card[:watchers]
      watchers.update_attributes :codename=>nil
      watchers.delete!
    end
    
    if send = Card[:send]
      send.update_attributes :codename=>nil
      send.delete!
    end
  end
end

