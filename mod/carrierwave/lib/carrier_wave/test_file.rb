module CarrierWave
  # Helper module for making test files in carrierwave available to tests
  module TestFile
    def self.path filename
      Cardio::Mod.fetch("carrierwave").subpath "data", "files", filename
    end
  end
end
