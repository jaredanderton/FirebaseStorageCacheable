#
# Be sure to run `pod lib lint FirebaseStorageCacheable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FirebaseStorageCacheable'
  s.version          = '0.1.2'
  s.summary          = 'FirebaseStorageCacheable is a libary to that downloads and caches the latest version of a file Firebase Storage.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library allows you download and cache files hosted in Firebase Storage.

It uses the timestamps of your local file, compared to the timestamp of the remote file (by using the file meta information), to determine if the remote file is newer.

The `update`, replaces the local file with a copy of the remote one. The API includes onComplete and onError closures as parameters to keep your code loosely coupled.

When updatig a file, you may also provide an onProgress closure to can inform your users of the download progress. Or you can let them know they have up-to-date data.

It also supports copying a bundled file to the target location, as well, so your users don't have to download your app, then download the data next, before using your app.
                       DESC

  s.homepage         = 'https://github.com/jaredanderton/FirebaseStorageCacheable'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jaredanderton' => 'jared@andertondev.com' }
  s.source           = { :git => 'https://github.com/jaredanderton/FirebaseStorageCacheable.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'FirebaseStorageCacheable/Classes/**/*'
  s.swift_version = '4.2'
  s.platform = :ios, '10.0'
  s.static_framework = true
  
  # s.resource_bundles = {
  #   'FirebaseStorageCacheable' => ['FirebaseStorageCacheable/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Firebase/Storage', '~> 3.1'
end
