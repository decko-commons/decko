format :html do
  def task_row task, mod
    base = "#{mod}_task_#{task}"
    [
      link_to_card(:admin, t("#{base}_link_text"), path: { action: :update, task: task }),
      t("#{base}_description")
    ]
  end

  def task_table tasks
    table_content = tasks.map do |task, task_config|
      task_row task, task_config[:mod]
    end
    table table_content, header: %w[Task Description]
  end
end