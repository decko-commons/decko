require "csv"

namespace :card do
  namespace :export do
    desc "export all cards to csv"
    task csv: :environment do
      parse_options :csv do
        add_opt :f, :file, "file name"
      end
      filename = options[:file] || "cards.csv"
      puts "Exporting all card data to #{filename}..."
      File.open(filename, "w") { |f| f.write to_csv }
    end
  end
end

private

def to_csv
  attributes = %w[id name codename type content]

  CSV.generate(headers: true) do |csv|
    csv << attributes
    Card.all.each do |card|
      csv << attributes.map { |attr| card.send(attr) }
    end
  end
end
