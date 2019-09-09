if defined?(CypressOnRails)
  CypressOnRails.configure do |c|
    c.cypress_folder = File.join Decko.gem_root, "spec", "cypress"
    # WARNING!! CypressOnRails can execute arbitrary ruby code
    # please use with extra caution if enabling on hosted servers or starting your
    # local server on 0.0.0.0
    c.use_middleware = Rails.env.cypress? || ENV["CYPRESS_DEV"]
    c.logger = Rails.logger
  end
end
