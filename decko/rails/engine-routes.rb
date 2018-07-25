# -*- encoding : utf-8 -*-

Decko::Engine.routes.draw do
  files = Decko::Engine.config.files_web_path
  file_matchers = { id: /[^-]+/, explicit_file: true, rev_id: /[^-]+/ }

  root "card#read"

  # explicit file request
  get({ "#{files}/:id/:rev_id(-:size).:format" => "card#read" }.merge(file_matchers))

  # DEPRECATED (old file and asset requests)
  get({ "#{files}/:id(-:size)-:rev_id.:format" => "card#read" }.merge(file_matchers))
  %w[assets javascripts jasmine].each do |prefix|
    get "#{prefix}/*id" => "card#asset"
  end

  # Standard GET request
  get "(/wagn)/:id(.:format)" => "card#read"  # /wagn is deprecated

  # Alternate GET requests
  get "new/:type" => "card#read", view: "new" # common case for card without id
  get ":id/view/:view(.:format)" => "card#read" # simplifies API documentation

  # RESTful (without id)
  post   "/" => "card#create"
  put    "/" => "card#update"
  patch  "/" => "card#update"
  delete "/" => "card#delete"

  # RESTful (with id)
  match ":id(.:format)" => "card#create", via: :post
  match ":id(.:format)" => "card#update", via: :put
  match ":id(.:format)" => "card#update", via: :patch
  match ":id(.:format)" => "card#delete", via: :delete

  # explicit GET alternatives for transactions
  %w[create read update delete asset].each do |action|
    get "(card)/#{action}(/:id(.:format))"  => "card", action: action
  end

  # for super-explicit over-achievers
  match "(card)/create(/:id(.:format))" => "card#create", via: [:post, :patch]
  match "(card)/update(/:id(.:format))" => "card#update", via: [:post, :put, :patch]
  match "(card)/delete(/:id(.:format))" => "card#delete", via: :delete

  # Wildcard for bad addresses
  get "*id" => "card#read", view: "bad_address"
end
