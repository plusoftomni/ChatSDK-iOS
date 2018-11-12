#
# Be sure to run `pod lib lint PlusoftChatSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PlusoftChatSDK'
  s.version          = '0.1.1'
  s.summary          = 'Integrate your app with Plusoft\'s Chats or Chatbots Solutions.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Integrate your app with Plusoft's Chats or Chatbots Solutions.
For more information: www.plusoft.com.br
                       DESC

  s.homepage         = 'https://github.com/plusoftomni/chatsdk-ios.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Danilo Rolim Honorato' => 'danilohonorato@plusoft.com.br' }
  s.source           = { :git => 'https://github.com/plusoftomni/chatsdk-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'PlusoftChatSDK/Classes/*.swift'
  
  # s.resource_bundles = {
  #   'PlusoftChatSDK' => ['PlusoftChatSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'WebKit'
  s.dependency 'Alamofire', '~> 4.6.0'
  s.dependency 'SwiftyJSON', '~> 4.0.0'
  s.swift_version = "4"
end
