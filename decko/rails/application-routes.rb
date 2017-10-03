Decko.application.routes.draw do
  rel_root = Cardio.config.relative_url_root
  if !Rails.env.production? && Object.const_defined?(:JasmineRails)
    engine = Object.const_get(:JasmineRails).const_get :Engine
    mount engine => "#{rel_root}/specs"
  end
  mount Decko::Engine => "#{rel_root}/"
end
