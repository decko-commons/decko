# ## What are Machines?
# {Machine} and {MachineInput} together implement a kind of observer pattern.
# {Machine} processes a collection of input cards to generate an output card
# (a {Set::Type::File} card by default). If one of the input cards is changed
# the output card will be updated.
#
# The classic example: A style card observes a collection of css and sccs card
# to generate a file card with a css file that contains the assembled
# compressed  css.
#
# ## Using Machines
# Include the Machine module in the card set that is supposed to produce the
# output card. If the output card should be automatically updated when a input
# card is changed the input card has to be in a set that includes the
# MachineInput module.
#
# The default machine:
#
#  -  uses its item cards as input cards or the card itself if there are no
# item cards;
#  -  can be changed by passing a block to collect_input_cards
#  -  takes the raw view of the input cards to generate the output;
#  -  can be changed by passing a block to machine_input (in the input card
# set)
#  -  stores the output as a .txt file in the '+machine output' card;
#  -  can be changed by passing a filetype and/or a block to
#     store_machine_output
#
#
# ## How does it work?
# Machine cards have a '+machine input' and a '+machine output' card. The
# '+machine input' card is a pointer to all input cards. Including the
# MachineInput module creates an 'on: save' event that runs the machines of
# all cards that are linked to that card via the +machine input pointer.
module MachineClassMethods
  attr_accessor :output_config

  def collect_input_cards &block
    define_method :engine_input, &block
  end

  def prepare_machine_input &block
    define_method :before_engine, &block
  end

  def machine_engine &block
    define_method :engine, &block
  end

  def store_machine_output args={}, &block
    output_config.merge!(args)
    return unless block_given?
    define_method :after_engine, &block
  end
end

card_accessor :machine_output, type: :file
card_accessor :machine_input, type: :pointer

def before_engine
end

def engine_input
  # TODO: replace with call of extended_item_cards
  # traverse through all levels of pointers and
  # collect all item cards as input
  items = [self]
  new_input = []
  already_extended = {} # avoid loops
  loop_limit = 5
  until items.empty?
    item = items.shift
    next if item.trash || already_extended[item.id].to_i > loop_limit
    if item.item_cards == [item] # no pointer card
      new_input << item
    else
      # item_cards instantiates non-existing cards
      # we don't want those
      items.insert(0, item.item_cards.reject(&:unknown?))
      items.flatten!

      new_input << item if item != self && item.known?
      already_extended[item] = already_extended[item].to_i + 1
    end
  end
  new_input
end

def engine input
  input
end

def after_engine output
  filetype = output_config[:filetype]
  file = Tempfile.new [id.to_s, ".#{filetype}"]
  file.write output
  file.rewind
  Card::Auth.as_bot do
    p = machine_output_card
    p.file = file
    p.save!
  end
  file.close
  file.unlink
end

view :machine_output_url do
  machine_output_url
end

class << self
  def included host_class
    host_class.extend(MachineClassMethods)
    host_class.mattr_accessor :output_config
    host_class.output_config = { filetype: "txt" }

    define_machine_events host_class
  end

  def define_machine_events host_class
    event_suffix = host_class.name.tr ":", "_"
    event_name = "reset_machine_output_#{event_suffix}".to_sym
    host_class.event event_name, after: :expire_related, changed: :content, on: :save do
      reset_machine_output
    end
  end
end

include_set Abstract::Lock

def run_machine joint="\n"
  before_engine
  output =
    input_item_cards.map do |input_card|
      run_engine input_card
    end.select(&:present?).join(joint)
  after_engine output
end

def direct_machine_input? input_card
  !input_card.collection? ||
    input_card.respond_to?(:machine_input)
end

def run_engine input_card
  return unless direct_machine_input? input_card
  if (cached = fetch_cache_card(input_card)) && cached.content?
    return cached.content
  end

  engine(input_from_card(input_card)).tap do |output|
    cache_output_part input_card, output
  end
end

def input_from_card input_card
  if input_card.respond_to? :machine_input
    input_card.machine_input
  else
    input_card.format._render_raw
  end
end

def make_machine_output_coded mod=:machines
  update_machine_output
  Card::Auth.as_bot do
    ENV["STORE_CODED_FILES"] = "true"
    machine_output_card.update! storage_type: :coded, mod: mod,
                                codename: machine_output_codename
    ENV["STORE_CODED_FILES"] = nil
  end
end

def machine_output_codename
  machine_output_card.name.parts.map do |part|
    Card[part].codename&.to_s || Card[part].name.safe_key
  end.join "_"
end

def input_item_cards
  machine_input_card.item_cards
end

def machine_output_url
  ensure_machine_output
  machine_output_card.file.url # (:default, timestamp: false)
  # to get rid of additional number in url
end

def machine_output_path
  ensure_machine_output
  machine_output_card.file.path
end


