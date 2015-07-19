module TrafficSpy
  class Source < ActiveRecord::Base
    validates_presence_of :identifier, :root_url

    has_many :payloads
    has_many :urls, through: :payloads
    has_many :browsers, through: :payloads
    has_many :operating_systems, through: :payloads
    has_many :screen_resolutions, through: :payloads

    def most_requested_urls
      urls.group_by { |url| url}
          .map { |url, value| [url, value.count] }
          .sort_by { |url, count| count}
          .reverse
          .to_h
    end

    def browser_breakdown
      browsers.group_by { |browser| browser}
          .map { |browser, value | [browser, value.count] }
          .sort_by { |browser, count|  count}
          .reverse
          .to_h
    end

    def os_breakdown
      operating_systems.group_by { |operating_system| operating_system}
          .map { |operating_system, value | [operating_system, value.count] }
          .sort_by { |operating_system, count| count}
          .reverse
          .to_h
    end

    def screen_resolution_breakdown
      screen_resolutions.group_by { |screen_resolution| screen_resolution}
          .map { |screen_resolution, value | [screen_resolution, value.count] }
          .sort_by { |screen_resolution, count| count}
          .reverse
          .to_h
    end

    def avg_response_times_per_url
      urls_response_times.map do |url, response_times|
        [url, (response_times.reduce { |sum, time| sum + time }.to_f / response_times.size).round(2)]
      end.to_h
    end

    def most_received_events
      payloads.group(:event).count.map { |key, value| [key.name.to_sym, value] }.reverse.to_h
    end



    private

    def get_url(payload)
      payload.url.address
    end

    def urls
      payloads.map do |payload|
        payload.url.address
      end
    end

    def url_counts
      urls.reduce(Hash.new(0)) {|h, v| h[v] += 1; h}
    end

    def browsers
      payloads.map do |payload|
        payload.browser.name
      end
    end

    def browser_counts
      browsers.reduce(Hash.new(0)) {|h, v| h[v] += 1; h}
    end

    def operating_systems
      payloads.map do |payload|
        payload.operating_system.name
      end
    end

    def operating_system_counts
      operating_systems.reduce(Hash.new(0)) {|h, v| h[v] += 1; h}
    end

    def screen_resolutions
      payloads.map do |payload|
        w = payload.screen_resolution.width
        h = payload.screen_resolution.height
        "#{w} X #{h}"
      end
    end

    def screen_resolution_counts
      screen_resolutions.reduce(Hash.new(0)) {|h, v| h[v] += 1; h}
    end

    def urls_response_times
      urls_response_times = Hash.new{ |h,k| h[k] = [] }
      payloads.each do |payload|
        urls_response_times[get_url(payload).to_sym] << payload.responded_in
      end
      urls_response_times
    end

  end
end
