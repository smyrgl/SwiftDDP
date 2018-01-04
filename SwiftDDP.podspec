Pod::Spec.new do |s|
  s.name             = "SwiftDDP"
  s.version          = "1.0.0"
  s.summary          = "A DDP Client for communicating with Meteor servers, written in Swift. Supports OAuth login with Facebook, Google, Twitter & Github."

  s.description      = <<-DESC "A DDP Client for communicating with DDP Servers (Meteor JS), written in Swift. Supports OAuth authentication with Facebook, Google, Twitter & Github."
                       DESC

  s.homepage         = "https://github.com/smyrgl/SwiftDDP"
  s.license          = 'MIT'
  s.author           = { "John Tumminaro" => "john@tumminaro.com" }
  s.source           = { :git => "https://github.com/smyrgl/SwiftDDP.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/psiegesmund'

  s.requires_arc = true
  s.platform = :ios, '9.0'
  s.source_files = 'SwiftDDP/**/*.swift'

  s.dependency 'CryptoSwift'
  s.dependency 'Starscream'
  s.dependency 'SwiftyBeaver'

end
