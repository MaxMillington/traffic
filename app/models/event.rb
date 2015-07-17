module TrafficSpy
  class Event < ActiveRecord::Base
    has_many :payloads

    def requested_at
      payloads.pluck(:requested_at)
    end

    def hour_parser
      requested_at.map do |time|
        kangaroo = Time.parse(time)
        kangaroo.strftime("%H")
      end
    end

    def hasher
      hour_parser.group_by do |x|
          x
      end.map do |key, value|
        [key, value.count]
      end.to_h
    end

  end
end
