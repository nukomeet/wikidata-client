module Wikidata
  module Property
    class Time < Wikidata::Property::Base
      DATE_PRECISION = [
        { key: nil, value: 1_000_000_000 * 365 * 24 * 3600 },
        { key: nil, value: 100_000_000 * 365 * 24 * 3600 },
        { key: nil, value: 10_000_000 * 365 * 24 * 3600 },
        { key: nil, value: 1_000_000 * 365 * 24 * 3600 },
        { key: nil, value: 100_000 * 365 * 24 * 3600 },
        { key: nil, value: 10_000 * 365 * 24 * 3600 },
        { key: nil, value: 1000 * 365 * 24 * 3600 },
        { key: :century, value: 100 * 365 * 24 * 3600 },
        { key: :decade, value: 10 * 365 * 24 * 3600 },
        { key: :year, value: 365 * 24 * 3600 },
        { key: :month, value: 30 * 24 * 3600 },
        { key: :day, value: 24 * 3600 },
        { key: nil, value: 3600 },
        { key: nil, value: 60 },
        { key: nil, value: 1 }
      ].freeze

      DAYS_IN_MONTH = [
        nil,
        31,
        28,
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31
      ].freeze

      def date
        return @date if @date
        d = Hash[[:year, :month, :day, :hour, :min, :sec].zip(
          value.time.scan(/(-?\d+)-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/).first.map(&:to_i)
        )]
        [:month, :day].each do |k|
          d[k] = ((d[k]).zero? ? 1 : d[k])
        end
        @date ||= DateTime.new(*d.values)
      end

      def timestamp
        date.to_time.utc.to_i
      end

      def precision
        DATE_PRECISION[value.precision.to_i][:value]
      end

      def precision_key
        DATE_PRECISION[value.precision.to_i][:key]
      end

      def after
        value.after
      end

      def before
        value.before
      end

      def range
        @range ||= if before.to_i.zero? && after.to_i.zero? && precision_key
                     send(:"#{precision_key}_range")
                   else
                     generic_range
                   end
      end

      protected

      def generic_range
        from = before > 0 ? timestamp - (before.to_i * precision) : timestamp
        to = after > 0 ? timestamp + (after.to_i * precision) : timestamp

        (to_datetime ::Time.at(from).utc)..(to_datetime ::Time.at(to).utc)
      end

      def century_range
        century = date.year / 100
        if date.year > 0
          from = DateTime.new((century - 1) * 100 + 1, 1, 1, 0, 0, 0)
          to = DateTime.new(century * 100, 12, 31, 23, 59, 59)
        else
          from = DateTime.new(century * 100, 1, 1, 0, 0, 0)
          to = DateTime.new((century + 1) * 100 - 1, 12, 31, 23, 59, 59)
        end
        (from..to)
      end

      def year_range
        from = DateTime.new(date.year, 1, 1, 0, 0, 0)
        to = DateTime.new(date.year, 12, 31, 23, 59, 59)
        (from..to)
      end

      def decade_range
        decade = date.year.round(-1)
        if decade > 0
          from = DateTime.new(decade, 1, 1, 0, 0, 0)
          to = DateTime.new(decade + 9, 12, 31, 23, 59, 59)
        else
          from = DateTime.new(decade - 9, 1, 1, 0, 0, 0)
          to = DateTime.new(decade, 12, 31, 23, 59, 59)
        end
        (from..to)
      end

      def month_range
        last_day = if date.month == 2 && Date.gregorian_leap?(date.year)
                     29
                   else
                     DAYS_IN_MONTH[date.month]
                   end
        from = DateTime.new(date.year, date.month, 1, 0, 0, 0)
        to = DateTime.new(date.year, date.month, last_day, 23, 59, 59)
        (from..to)
      end

      def day_range
        from = DateTime.new(date.year, date.month, date.day, 0, 0, 0)
        to = DateTime.new(date.year, date.month, date.day, 23, 59, 59)
        (from..to)
      end

      def to_datetime(t)
        DateTime.new(t.year, t.month, t.day, t.hour, t.min, t.sec)
      end
    end
  end
end
