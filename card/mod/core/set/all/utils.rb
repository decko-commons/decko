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
    card.safe_update! attribs
  end

  private

  def resolve_file_attributes! attribs
    %i[image file].each do |attach|
      next unless attribs[attach].is_a?(String)

      attribs[attach] = ::File.open(attribs[attach])
    end
  end

  def mergeable? card, pristine_only
    return true unless pristine_only

    !card.pristine?
  end
end

# separate name and other attributes
def safe_update! attribs
  separate_name_update! attribs.delete("name") unless new?
  update! attribs if attribs.present?
end

def separate_name_update! new_name
  return if new_name.to_s == name.to_s

  update! name: new_name
end

# rubocop:disable Style/GlobalVars
def measure desc
  $times ||= {}
  res = nil
  t = Benchmark.measure do
    res = yield
  end
  $times[desc] = $times.key?(desc) ? t + $times[desc] : t
  puts "#{desc}: #{t}".red
  res
end
# rubocop:enable Style/GlobalVars

def mod_root modname
  if (spec = Gem::Specification.find_by_name "card-mod-#{modname}")
    spec.full_gem_path
  else
    "#{Cardio.gem_root}/mod/#{modname}"
  end
end

delegate :t, to: Cardio

format do
  delegate :t, to: Cardio
  delegate :measure, to: :card
end
