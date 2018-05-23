module ClassMethods
  def merge_list attribs, opts={}
    unmerged = []
    attribs.each do |row|
      if merge row["name"], row, opts
        Rails.logger.info "merged #{row['name']}"
      else
        unmerged.push row
      end
    end

    if unmerged.empty?
      Rails.logger.info "successfully merged all!"
    else
      unmerged_json = JSON.pretty_generate unmerged
      report_unmerged_json unmerged_json, opts[:output_file]
    end
    unmerged
  end

  def report_unmerged_json unmerged_json, output_file
    if output_file
      ::File.open output_file, "w" do |f|
        f.write unmerged_json
      end
    else
      Rails.logger.info "failed to merge:\n\n#{unmerged_json}"
    end
  end

  def merge name, attribs={}, opts={}
    # puts "merging #{name}"
    card = fetch name, new: {}
    %i[image file].each do |attach|
      next unless attribs[attach] && attribs[attach].is_a?(String)
      attribs[attach] = ::File.open(attribs[attach])
    end
    if opts[:pristine] && !card.pristine?
      false
    else
      card.update_attributes! attribs
    end
  end
end
