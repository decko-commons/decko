card_reader :contextual_class
card_reader :disappear
card_reader :message

def deliver context
  success.flash alert_message(context)
end

def alert_message context
  mcard = message.present? ? message_card : self
  format(:html).alert_message context, mcard
end

format :html do
  def alert_message context, message_card
    mformat = subformat message_card
    alert card.alert_class, true, card.disappear? do
      mformat.contextual_content context, view: alert_view(mformat)
    end
  end

  def alert_view format
    format.respond_to?(:notify) ? format.notify : :core
  end
end

def disappear?
  disappear.present? ? disappear_card.checked? : true
end

def alert_class
  contextual_class.present? ? contextual_class_card.first_name : :success
end
