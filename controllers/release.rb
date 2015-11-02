require 'ruby_apk'
require 'nokogiri'

get '/app_release/android' do
  @app_release = AppRelease.first
  if @app_release
    json @app_release
  else
    json version_code: 0
  end
end

post '/admin/app_release/android' do
  @app_release = AppRelease.first_or_initialize
  @app_release.message = params[:message]

  if params[:archive]
    apk = Android::Apk.new(params[:archive][:tempfile].path)
    manifest = apk.manifest
    xml = Nokogiri::XML(manifest.to_xml)
    version_code = xml.root['android:versionCode'].to_i
    @app_release.version_code = version_code

    path = upload_file_to_s3(params[:archive], key: params[:archive][:filename], bucket: settings.s3[:storage_bucket])
    @app_release.download_url = settings.cdn[:storage_host] + path
  end

  @app_release.save
  json @app_release
end
