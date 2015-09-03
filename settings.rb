require 'aws-sdk'

set :sms,
  username: 'vipswj',
  password: 'Tch123456'

set :security_code,
  template: '您的验证码是%{security_code}, 请在三分钟内输入',
  expire: 180

Aws.config.update(
  region: 'cn-north-1',
  credentials: Aws::Credentials.new('AKIAPAG2UTMB6E2ZFQTQ', '4p182v6XYs85g/0WWBMl+mvk/nseEkQoPrt//xBE')
)

set :s3,
  bucket: 'infection-development',
  host: 'infection-development.s3-website.cn-north-1.amazonaws.com.cn'
