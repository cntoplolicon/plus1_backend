require 'net/http'

def publish_notification(installationId, content)
  Thread.new do
    uri = URI(settings.leancloud[:push_uri])
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req['X-LC-Id'] = settings.leancloud[:app_id]
    req['X-LC-Key'] = settings.leancloud[:app_key]
    payload = {where: {installationId: installationId},
               data: {content: content, action: 'com.oneplusapp.NOTIFICATION'}}
    req.body = payload.to_json
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.start do |h|
      h.request(req)
    end
  end
end

def build_notification_content(user_id, type, message)
  {user_id: user_id || 0, type: type, publish_time: Time.zone.now, content: message}.to_json
end
