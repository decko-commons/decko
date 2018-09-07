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
    return unless mergeable? card, opts[:pristine]
    resolve_file_attributes! attribs
         if !card.new? && (new_name = attribs.delete("name"))
        card.update_attributes! name: new_name unless new_name.to_s == card.name.to_s
        card = fetch new_name
      end
      card.update_attributes! attribs if attribs.present?
    end
  end

  private

  def resolve_file_attributes! attribs
    %i[image file].each do |attach|
      next unless attribs[attach] && attribs[attach].is_a?(String)
      attribs[attach] = ::File.open(attribs[attach])
    end
  end

  def mergeable? card, pristine_only
    return true unless pristine_only
    !card.pristine?
  end
end
