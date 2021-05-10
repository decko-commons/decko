class IncreaseTextSizeForDelayedJobs < ActiveRecord::Migration[5.1]
  def self.up
    change_column :delayed_jobs, :handler, :text, limit: 16_777_215
  end

  def self.down
    change_column :delayed_jobs, :handler, :text
  end
end
