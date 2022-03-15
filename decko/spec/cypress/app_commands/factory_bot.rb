Array.wrap(command_options).each do |factory_options|
  factory_method = factory_options.shift
  begin
    logger.debug "running #{factory_method}, #{factory_options}"
    CypressOnRails::SmartFactoryWrapper.public_send(factory_method, *factory_options)
  rescue StandardError => e
    logger.error "#{e.class}: #{e.message}"
    logger.error e.backtrace[0..50].join("\n")
    logger.error e.record.inspect.to_s if e.is_a?(ActiveRecord::RecordInvalid)
    raise e
  end
end
