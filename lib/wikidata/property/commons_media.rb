module Wikidata
  module Property
    class CommonsMedia < Wikidata::Property::Base
      BASE_PAGE_URL = 'https://commons.wikimedia.org/wiki/File:%s.%s'.freeze
      IMAGE_URL = 'https://upload.wikimedia.org/wikipedia/commons/%s/%s/%s.%s'.freeze
      THUMB_IMAGE_URL = 'https://upload.wikimedia.org/wikipedia/commons/thumb/%s/%s/%s.%s/%ipx-%s.%s'.freeze

      def page_url
        @page_url ||= format BASE_PAGE_URL, basename, extension
      end

      def url(size = nil)
        format(size ? THUMB_IMAGE_URL : IMAGE_URL,
               md5[0],
               md5[0..1],
               basename,
               extension,
               size,
               basename,
               extension,
               thumb_extension)
      end

      def md5
        @md5 ||= Digest::MD5.hexdigest([basename, extension].join('.'))
      end

      def basename
        @basename ||= name.tr(' ', '_')
      end

      def name
        @name ||= File.basename(value, ".#{extension}")
      end

      def thumb_extension
        @thumb_ext ||= extension == 'svg' ? 'svg.png' : extension
      end

      def extension
        @ext ||= File.extname(value).tr('.', '')
      end
    end
  end
end
