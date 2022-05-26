# extend core Ruby object classes
module CoreExtensions
  # extend core String class
  module String
    def number?
      true if Float(self)
    rescue StandardError
      false
    end

    def url?
      start_with?("http://", "https://")
    end
  end
end
