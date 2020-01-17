class ModInflector < Zeitwerk::Inflector
  def camelize basename, abspath
    ActiveSupport::Dependencies::ZeitwerkIntegration::Inflector.camelize(basename, abspath)

    # if basename =~ /\Ahtml_(.*)/
    #   ActiveSupport::Dependencies::ZeitwerkIntegration::Inflector.camelize(basename, abspath)
    #   # "HTML" + super($1, abspath)
    # else
    #   super
    # end
  end

  def inflect overrides
    ActiveSupport::Dependencies::ZeitwerkIntegration::Inflector.inflect(overrides)
  end
end
