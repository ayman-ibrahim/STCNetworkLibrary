#
# Be sure to run `pod lib lint STCNetworkLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'STCNetworkLibrary'
  s.version          = '0.1.1'
  s.summary          = 'STC iOS App network library to facilitate http calls'
  s.swift_versions   = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    'STCNetworkLibrary is a network library for internal use in STC internal projects support parallel calls, caching and others ..'
                       DESC

  s.homepage         = 'https://github.com/ayman-ibrahim/STCNetworkLibrary'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ayman-ibrahim' => 'ayman.ibrahim.alim@gmail.com' }
  s.source           = { :git => 'https://github.com/ayman-ibrahim/STCNetworkLibrary.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'STCNetworkLibrary/Classes/**/*'
  
  # s.resource_bundles = {
  #   'STCNetworkLibrary' => ['STCNetworkLibrary/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
