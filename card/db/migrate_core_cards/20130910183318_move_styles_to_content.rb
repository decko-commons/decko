# -*- encoding : utf-8 -*-

class MoveStylesToContent < Cardio::Migration::Core
  def up
    dir = File.join data_path, "1.12_stylesheets"
    %w[right_sidebar common classic_cards traditional].each do |sheetname|
      Card["style: #{sheetname}"].update! codename: nil,
                                          content: File.read("#{dir}/#{sheetname}.scss")
    end
  end
end
