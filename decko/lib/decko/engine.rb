module Decko
  # Decko::Engine inherits from Rails Engine
  # see https://guides.rubyonrails.org/engines.html
  class Engine < ::Rails::Engine
    paths.add "config/routes.rb", with: "config/engine_routes.rb"

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
    end
  end
end
