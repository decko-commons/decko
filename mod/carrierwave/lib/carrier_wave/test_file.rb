module CarrierWave
  module TestFile
    def self.path filename
      Cardio::Mod.fetch("carrierwave").subpath "data", "files", filename
    end
  end
end
