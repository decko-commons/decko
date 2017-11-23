require "colorize"

namespace :card do
  namespace :create do
    # 1. Creates a js/coffee/css/scss file with the appropriate path in
    #    the given mod.
    #    If a card with the given name exists it copies the content to that
    #    file.
    # 2. Creates a self set file that loads the code file as content
    # 3. Creates a card migration that adds the code card to the script/style
    #    rule defined by DEFAULT_RULE. Override the rule_card_name
    #    method to change it.
    # @param mod [String] the name of the mod where the files are created
    # @param name [String] the card name
    # @param type supported options are js, coffee, css, scss
    # @param codename optional defaults to key of the name
    # @param force ["true", "false"] override existing files
    # @example
    #   rake card:create:codefile type=scss mod=standard name="script card"
    #                             codename=not_the_key force=true
    desc "create folders and files for scripts or styles"
    task codefile: :environment do
      set_default_rule_names
      with_params(:mod, :name, :type, codename: nil, force: false) do
        |mod, name, type, codename, force|
        Card::FileCardCreator.new(mod, name, type, codename, force == "true").create
      end
    end

    # override to which rule cards script and styles cards are added
    def set_default_rule_names
      # Card::FileCardCreator::ScriptCard.default_rule_name =
      # Card::FileCardCreator::StyleCard.default_rule_name =
    end

    # shortcut for create:codefile type=scss
    desc "create folders and files for stylesheet"
    task style: :environment do
      ENV["type"] ||= "scss"
      Rake::Task["card:create:codefile"].invoke
    end

    # shortcut for create:codefile type=coffee
    desc "create folders and files for script"
    task script: :environment do
      ENV["type"] ||= "coffee"
      Rake::Task["card:create:codefile"].invoke
    end

    # shortcut for create:codefile type=haml
    desc "create folders and files for script"
    task haml: :environment do
      ENV["type"] ||= "haml"
      Rake::Task["card:create:codefile"].invoke
    end

    def with_params *keys
      optional_params = keys.pop if keys.last.is_a? Hash
      return unless params_present?(*keys)
      values = keys.map { |k| ENV[k.to_s] }
      optional_params.each_pair do |k, v|
        values << (ENV[k.to_s] || v)
      end
      yield(*values)
    end

    def params_present? *env_keys
      missing = env_keys.select { |k| !ENV[k.to_s] }
      missing.each do |key|
        color_puts "missing parameter:", :red, key
      end
      missing.empty?
    end

    def color_puts colored_text, color, text=""
      puts "#{colored_text.send(color.to_s)} #{text}"
    end
  end
end
