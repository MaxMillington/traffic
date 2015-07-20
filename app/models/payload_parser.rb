module TrafficSpy
  class PayloadParser

    attr_reader :result

    def initialize(data, identifier)
      @digest     = Digest::SHA1.hexdigest(data.to_s)
      @data       = data
      @identifier = identifier
      @source = Source.find_by(identifier: identifier)
    end

    def validate
      if @source.blank?
        @result = {status: 403,
                   body: "application not registered"}
      elsif @data[:payload].blank?
        @result = {status: 400,
                   body: "missing payload"}
      elsif Payload.find_by(digest: Digest::SHA1.hexdigest(@data[:payload]))
        @result = {status: 403,
                   body: "already received request"}
      else
        save_payload_data
        @result = {status: 200, body: "OK"}
      end
    end

    private

    def missing_payload?
      @data.nil?
    end

    def already_received_request?
      Payload.exists?(digest: @digest)
    end

    def application_registered?
      Source.exists?(identifier: @identifier)
    end

    def save_payload_data
      @source.payloads.create(normalized_payload_data)
    end

    def normalized_payload_data

      user_agent = JSON.parse(@data[:payload])["userAgent"]
      platform = UserAgent.new(user_agent).platform
      browser = UserAgent.new(user_agent).name

      { digest: Digest::SHA1.hexdigest(@data[:payload]),
        url: Url.where(address: JSON.parse(@data[:payload])["url"]).first_or_create,
        requested_at: JSON.parse(@data[:payload])["requestedAt"],
        responded_in: JSON.parse(@data[:payload])["respondedIn"],
        referred_by: JSON.parse(@data[:payload])["referredBy"],
        request_type: JSON.parse(@data[:payload])["requestType"],
        event:           Event.where(name: JSON.parse(@data[:payload])["eventName"]).first_or_create,
        operating_system: OperatingSystem.where(name: platform).first_or_create,
        browser:         Browser.where(name: browser).first_or_create,
        screen_resolution: ScreenResolution.where(width: JSON.parse(@data[:payload])["resolutionWidth"],
                                                  height: JSON.parse(@data[:payload])["resolutionHeight"]).first_or_create
      }
    end
  end
end
