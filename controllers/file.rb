require 'aws-sdk'

Aws.config.update(
  region: 'cn-north-1',
  credentials: Aws::Credentials.new(settings.aws[:access_key_id], settings.aws[:secret_access_key])
)

def upload_file_to_s3(uploaded_file, options = {})
  s3 = Aws::S3::Client.new
  options = {
    key: "#{Time.zone.now.strftime('%Y-%m-%d')}/#{SecureRandom.uuid}#{File.extname(uploaded_file[:filename])}",
    bucket: settings.s3[:bucket]
  }.merge(options)
  s3.put_object(acl: 'public-read-write', bucket: options[:bucket], key: options[:key],
                content_type: uploaded_file[:type], body: uploaded_file[:tempfile])
  options[:key]
end
