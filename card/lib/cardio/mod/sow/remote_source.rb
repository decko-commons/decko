module Cardio
  class Mod
    class Sow
      # Fetch sow data from remote
      module RemoteSource
        def remote_source
          @remote_source ||=
            if @remote
              raise Card::Error::NotFound, "must specify name (-n)" unless @name

              URI.join(@remote, "/#{@name.cardname.url_key}/", "pod.yml")
            else
              @url
            end
        end

        def pod_from_url
          parsed_yaml = parse_pod_yaml yaml_from_url
          Array.wrap(parsed_yaml)
        rescue Psych::SyntaxError
          raise "Url #{@remote_source} provided invalid yaml"
        end

        def yaml_from_url
          @yaml_from_url ||= URI.open(@remote_source).read
        rescue OpenURI::HTTPError => e
          raise "#{@remote_source} not available\n#{e}"
        end
      end
    end
  end
end
