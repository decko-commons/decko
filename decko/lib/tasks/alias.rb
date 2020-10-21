def alias_task name, old_name
  t = Rake::Task[old_name]
  desc t.full_comment if t.full_comment
  task name, *t.arg_names do |_, args|
    # values_at is broken on Rake::TaskArguments
    args = t.arg_names.map { |a| args[a] }
    t.invoke(args)
  end
end

def append_to_namespace namespace, part
  [namespace, part].compact.join(":")
end

def link_task task, from: nil, to: nil, namespace: nil
  case task
  when Hash
    task.each do |key, val|
      link_task val, from: from, to: to ,
                  namespace: append_to_namespace(namespace, key)

    end
  when Array
    task.each do |t|
     link_task t, from: from, to: to, namespace: namespace
    end
  else
    shared_part = append_to_namespace namespace, task
    alias_task "#{from}:#{shared_part}", "#{to}:#{shared_part}"
  end
end