namespace :card do
  namespace :trash do
    desc "empty trash"
    task empty: :environment do
      Cardio::Utils.empty_trash
    end
  end
end
