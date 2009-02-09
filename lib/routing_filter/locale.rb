require 'i18n'
require 'routing_filter/base'

module RoutingFilter
  class Locale < Base
    # remove the locale from the beginning of the path, pass the path
    # to the given block and set it to the resulting params hash
    # Called whenever a url arrives from a client and needs to be parsed.
    def around_recognize(path, env, &block)
      locale = nil
      path.sub! %r(^/([a-zA-Z]{2})(?=/|$)) do locale = $1; '' end
      returning yield do |params|
        params[:locale] = locale if locale
      end
    end
    
    # urls are /always/ generated with a locale in this edition. This filter occurs
    # when you run resource_url or resource_path, or any other function which
    # constructs a url.
    def around_generate(*args, &block)
      locale = args.extract_options!.delete(:locale) || I18n.locale
      returning yield do |result|
        unless result.is_a? Array   # Functional tests pass an array through the stack.
          result.sub!(%r(^(http.?://[^/]*)?(.*))){ "#{$1}/#{locale}#{$2}" }
        end
      end
    end
  end
end