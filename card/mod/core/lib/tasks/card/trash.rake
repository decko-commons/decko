namespace :card do
  namespace :trash do
    desc "empty trash"
    task :empty do
      Cardio::Utils.empty_trash
    end
  end
end