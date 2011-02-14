module CloudSeed
  class Middleware
    CDN_ASSETS = ['text/css', 'application/javascript', 'text/javascript', 'image/', 'application/pdf', 'audio/', 'video/']
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

      mime = headers['Content-Type']
      
      if status == 200 && is_compressable?(mime)
        headers['Vary'] = 'Accept-Encoding'
      end

      if !is_cloudfront_request?(env) || status == 404 || is_cdn_asset?(mime)
        [status, headers, body]
      else
        [404, {}, ['Not found']]
      end
    end

    def is_cloudfront_request?(env)
      env['HTTP_USER_AGENT'] == 'Amazon CloudFront'
    end

    def is_cdn_asset?(mime)
      return true unless mime
      CDN_ASSETS.any?{|c| mime.start_with?(c) }
    end

    def is_compressable?(mime)
      return false unless mime
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
