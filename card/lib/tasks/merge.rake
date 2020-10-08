
namespace :card do
  namespace :merge do
    desc "merge import card data that was updated since the last push into " \
         "the the database"
    task merge: :environment do
      importer.merge
    end

    desc "merge all import card data into the the database"
    task merge_all: :environment do
      importer.merge all: true
    end
  end
end
