class Cardname
  module Danger
    def self.dangerous_methods
      bang_methods = String.instance_methods.select { |m| m.to_s.end_with?("!") }
      %i[replace concat clear].concat bang_methods
    end

    dangerous_methods.each do |m|
      define_method m do |*args, &block|
        reset
        super(*args, &block)
      end
    end

    private

    def reset
      self.class.reset_cache s
      instance_variables.each { |var| instance_variable_set var, nil }
    end
  end
end
