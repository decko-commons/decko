# extend core Ruby object classes
module CoreExtensions
  # extend core String class
  module String
    def url?
      start_with?("http://", "https://")
    end
  end
end
