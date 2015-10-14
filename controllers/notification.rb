require 'net/http'

def publish_notification(channel, content)
  uri = URI(settings.yunba[:api_uri])
  req = Net::HTTP::Post.new(uri)
  req['Content-Type'] = 'application/json'
  payload = {method: 'publish', appkey: settings.yunba[:app_key],
             seckey: settings.yunba[:secret_key], topic: channel, msg: content}
  req.body = payload.to_json
  Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
end

def build_notification_content(user_id, type, message)
  user_id ||= 0
  {user_id: user_id, type: type, publish_time: Time.zone.now, content: message}.to_json
end
