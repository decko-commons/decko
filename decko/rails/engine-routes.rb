# -*- encoding : utf-8 -*-

Decko::Engine.routes.draw do
  files = Decko::Engine.config.files_web_path
  file_matchers = { mark: /[^-]+/, explicit_file: true, rev_id: /[^-]+/ }

  root "card#read"

  # explicit file request
  get({ "#{files}/:mark/:rev_id(-:size).:format" => "card#read" }.merge(file_matchers))

  # DEPRECATED (old file and asset requests)
  get({ "#{files}/:mark(-:size)-:rev_id.:format" => "card#read" }.merge(file_matchers))
  %w[assets javascripts jasmine].each do |prefix|
    get "#{prefix}/*mark" => "card#asset"
  end

  # Standard GET requests
  get "(/wagn)/:mark(.:format)" => "card#read"  # /wagn is deprecated

  # Alternate GET requests
  get "new/:type" => "card#read", view: "new" # common case for card without mark
  get ":mark/view/:view(.:format)" => "card#read" # simplifies API documentation
  get "card/:view(/:mark(.:format))" => "card#read", view: /new|edit/ # legacy

  # RESTful (without mark)
  post   "/" => "card#create"
  put    "/" => "card#update"
  patch  "/" => "card#update"
  delete "/" => "card#delete"

  # RESTful (with mark)
  match ":mark(.:format)" => "card#create", via: :post
  match ":mark(.:format)" => "card#update", via: [:put, :patch]
  match ":mark(.:format)" => "card#delete", via: :delete

  # explicit GET alternatives for transactions
  %w[create read update delete asset].each do |action|
    get "(card)/#{action}(/:mark(.:format))"  => "card", action: action
  end

  # for super-explicit over-achievers
  match "(card)/create(/:mark(.:format))" => "card#create", via: [:post, :patch]
  match "(card)/update(/:mark(.:format))" => "card#update", via: [:post, :put, :patch]
  match "(card)/delete(/:mark(.:format))" => "card#delete", via: :delete

  # Wildcard for bad addresses
  get "*mark" => "card#read", view: "bad_address"
end
