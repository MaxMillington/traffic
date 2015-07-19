module TrafficSpy
  class Server < Sinatra::Base

    get '/' do
      erb :index
    end

    not_found do
      erb :error
    end

    post '/sources' do

      new_params = {identifier: params[:identifier], root_url: params[:rootUrl]}

      source = Source.new(new_params)
      if Source.find_by(identifier: source.identifier)
        status 403
        "identifier already exists"
      elsif source.save
        status 200
        body JSON.generate({:identifier=>source.identifier})
      else
        status 400
        body source.errors.full_messages.join(", ")
      end
    end

    get '/sources/:identifier' do |identifier|
      @details = Source.find_by(identifier: identifier)
      erb :application_details
    end

    post '/sources/:identifier/data' do |identifier|
      #payload = PayloadParser.new(params[:payload], identifier)
      #payload.validate
      #status payload.result[:status]
      #body payload.result[:body]
      #
      source = Source.find_by(identifier: identifier)

      if source.blank?
        status 403
        body "application not registered"
      elsif params[:payload].blank?
        status 400
        body "missing payload"
      elsif Payload.find_by(digest: Digest::SHA1.hexdigest(params[:payload]))
        status 403
        body "already received request"
      else

        user_agent = JSON.parse(params[:payload])["userAgent"]
        platform = UserAgent.new(user_agent).platform
        browser = UserAgent.new(user_agent).name

        payload = source.payloads.create(
        digest: Digest::SHA1.hexdigest(params[:payload]),
        url: Url.where(address: JSON.parse(params[:payload])["url"]).first_or_create,
        requested_at: JSON.parse(params[:payload])["requestedAt"],
        responded_in: JSON.parse(params[:payload])["respondedIn"],
        referred_by: JSON.parse(params[:payload])["referredBy"],
        request_type: JSON.parse(params[:payload])["requestType"],
        event:           Event.where(name: JSON.parse(params[:payload])["eventName"]).first_or_create,
        operating_system: OperatingSystem.where(name: platform).first_or_create,
        browser:         Browser.where(name: browser).first_or_create,
        screen_resolution: ScreenResolution.where(width: JSON.parse(params[:payload])["resolutionWidth"],
        height: JSON.parse(params[:payload])["resolutionHeight"]).first_or_create,

        )

        status 200
      end
    end

    get '/sources/:identifier/events/:event_name' do |identifier, event_name|
      source_id = Source.find_by(identifier: identifier).id
      if event = Event.find_by(name: event_name)
        payloads = Payload.where({source_id: source_id, event_id: event.id})
        requested_hrs = payloads.pluck(:requested_at).map { |requested_at| DateTime.parse(requested_at).hour }
        @event_count_by_hour = requested_hrs.group_by { |hr| hr }.map { |k, v| [k, v.count] }.to_h.sort
        @overall_count = requested_hrs.size
        @identifier = identifier
        @event = event_name
        erb :application_event_details
      else
        status 403
        body 'No event with the given name has been defined.'
      end
    end

    get '/sources/:identifier/events' do |identifier|
      @source = Source.find_by(identifier: identifier)
      if @source.most_received_events.length > 0
        erb :application_events_index
      else
        status 403
        body 'No events have been defined.'
      end
    end
    
  end
end
