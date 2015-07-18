module TrafficSpy
  class Event < ActiveRecord::Base
    has_many :payloads

    def requests_by_hour_count
      requested_at_hours.group_by { |hr| hr }.map { |k, v| [k, v.count] }.to_h
    end

    private

    def requested_ats
      payloads.pluck(:requested_at)
    end

    def requested_at_hours
      requested_ats.map { |time| DateTime.parse(time).hour }
    end

  end
end
