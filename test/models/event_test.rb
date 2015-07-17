require_relative '../test_helper'

module TrafficSpy
  class EventTest < ControllerTest

    def test_returns_hour_by_hour_breakdown_of_when_event_was_received
      populate
      event = Event.last
      binding.pry
      event.hour_parser


    end

    #we need requested_at and event_name and need to get all the requested_ats for
    #an event name, then we need to break down the times hour by hour and return
    #the data.


    private

    def populate
      register_application
      save_urls_to_table
      save_browsers_to_table
      save_os_to_table
      save_screen_resolutions_to_table
      save_events_to_table
      save_payloads_to_table
    end

    def register_application
      Source.create(identifier: "jumpstartlab", root_url: "http://jumpstartlab.com")
    end

    def save_urls_to_table
      Url.create(address: "http://jumpstartlab.com/blog")
      Url.create(address: "http://jumpstartlab.com")
      Url.create(address: "http://jumpstartlab.com/apply")
    end

    def save_browsers_to_table
      Browser.create(name: "Chrome")
      Browser.create(name: "Firefox")
      Browser.create(name: "Safari")
    end

    def save_os_to_table
      OperatingSystem.create(name: "Macintosh")
      OperatingSystem.create(name: "Windows")
      OperatingSystem.create(name: "Linux")
    end

    def save_screen_resolutions_to_table
      ScreenResolution.create(width: "800", height: "720")
      ScreenResolution.create(width: "1280", height: "720")
      ScreenResolution.create(width: "900", height: "540")
    end

    def save_events_to_table
      Event.create(name: "socialLogin")
      Event.create(name: "otherLogin")
      Event.create(name: "application")
    end

    def save_payloads_to_table
      source = Source.find_by(identifier: "jumpstartlab")
      payload_sample.each do |datum|
        source.payloads.create(datum)
      end
    end

    def payload_sample
      [{"digest":"6", "url_id":find_url_id("http://jumpstartlab.com/apply"),
        "browser_id":find_browser_id("Chrome"), "operating_system_id":find_os_id("Macintosh"),
        "screen_resolution_id":find_screen_resolution_id("1280", "720"),
        "response_time":6, "event_id": Event.find_by(name: "socialLogin").id,
        "requested_at":"2013-02-16 12:38:28 -0700"},
       {"digest":"3", "url_id":find_url_id("http://jumpstartlab.com"),
        "browser_id":find_browser_id("Chrome"), "operating_system_id":find_os_id("Windows"),
        "screen_resolution_id":find_screen_resolution_id("800", "720"),
        "response_time":8, "event_id": Event.find_by(name: "otherLogin").id,
        "requested_at":"2013-02-16 21:38:28 -0700"},
       {"digest":"4", "url_id":find_url_id("http://jumpstartlab.com/blog"),
        "browser_id":find_browser_id("Firefox"), "operating_system_id":find_os_id("Macintosh"),
        "screen_resolution_id":find_screen_resolution_id("1280", "720"),
        "response_time":7, "event_id": Event.find_by(name: "socialLogin").id,
        "requested_at":"2013-02-16 21:38:28 -0700"},
       {"digest":"1", "url_id":find_url_id("http://jumpstartlab.com/apply"),
        "browser_id":find_browser_id("Safari"), "operating_system_id":find_os_id("Linux"),
        "screen_resolution_id":find_screen_resolution_id("800", "720"),
        "response_time":6, "event_id": Event.find_by(name: "application").id,
        "requested_at":"2013-02-16 12:38:28 -0700"},
       {"digest":"6", "url_id":find_url_id("http://jumpstartlab.com/apply"),
        "browser_id":find_browser_id("Safari"), "operating_system_id":find_os_id("Windows"),
        "screen_resolution_id":find_screen_resolution_id("1280", "720"),
        "response_time":6, "event_id": Event.find_by(name: "application").id,
        "requested_at":"2013-02-16 12:38:28 -0700"},
       {"digest":"6", "url_id":find_url_id("http://jumpstartlab.com"),
        "browser_id":find_browser_id("Chrome"), "operating_system_id":find_os_id("Macintosh"),
        "screen_resolution_id":find_screen_resolution_id("900", "540"),
        "response_time":8, "event_id": Event.find_by(name: "application").id,
        "requested_at":"2013-02-16 21:38:28 -0700"}]
    end

    def find_url_id(url)
      Url.find_by(address: url).id
    end

    def find_browser_id(url)
      Browser.find_by(name: url).id
    end

    def find_os_id(url)
      OperatingSystem.find_by(name: url).id
    end

    def find_screen_resolution_id(width, height)
      ScreenResolution.find_by_width_and_height(width, height).id
    end

  end
end