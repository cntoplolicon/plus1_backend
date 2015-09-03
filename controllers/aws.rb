require 'aws-sdk'

def upload_file_to_s3(uploaded_file)
  s3 = Aws::S3::Client.new
  key = "#{Time.zone.now.strftime('%Y-%m-%d')}/#{SecureRandom.uuid}#{File.extname(uploaded_file[:filename])}"
  s3.put_object(acl: 'public-read-write', bucket: settings.s3[:bucket], key: key,
                content_type: uploaded_file[:type], body: uploaded_file[:tempfile])
  "#{settings.s3[:host]}/#{key}"
end
