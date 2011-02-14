module CloudSeed
  class Middleware
    COMPRESSABLE = ["javascript", "json", "atom+xml", "xml", "pdf"].map do |f|
        "application/#{f}"
      end
    attr_accessor :app

    def initialize(app)
      self.app = app
    end

    def call(env)
      munge_version(env)

      status, headers, body = app.call(env)
      
      if is_compressable?(headers['Content-Type'])
        headers['Vary'] = 'Accept-Encoding'
      end

      [status, headers, body]
    end

    def is_compressable?(mime)
      return mime.start_with?('text/') ||
        COMPRESSABLE.any?{|c| mime.start_with?(c) }
    end

    def munge_version(env)
      if (v = extract_version(env['PATH_INFO']))
        env['PATH_INFO'] = v.first
        
        qs = env['QUERY_STRING']
        if qs.nil? || qs.strip == ''
          qs = v[1]
        else
          qs = "&#{v[1]}"
        end
        env['QUERY_STRING'] = qs
      end
    end

    def extract_version(path)
      if path =~ /(.+)\.v(\w+)(\.\w+)?$/
        [$1 + $3, $2]
      else
        nil
      end
    end
  end
end
