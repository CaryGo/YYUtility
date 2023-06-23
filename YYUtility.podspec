#
# Be sure to run `pod lib lint YYUtility.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YYUtility'
  s.version          = '0.1.0'
  s.summary          = '一个通用的Swift扩展组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
YYUtility是一个通用的扩展组件，整理了iOS开发中常用的一些方法与扩展。
                       DESC

  s.homepage         = 'https://github.com/CaryGo/YYUtility'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CaryGo' => 'guojiashuang@live.com' }
  s.source           = { :git => 'https://github.com/CaryGo/YYUtility.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.requires_arc = true
  
  s.subspec 'CommonCrypto' do |ss|
    ss.source_files = 'YYUtility/Classes/CommonCrypto/*'
    s.public_header_files = 'YYUtility/Classes/CommonCrypto/*.{h}'
  end
  
  s.subspec 'Extension' do |ss|
    ss.source_files = 'YYUtility/Classes/Extension/*'
    s.public_header_files = 'YYUtility/Classes/Extension/*.{h}'
  end
  
  s.subspec 'Utils' do |ss|
    ss.source_files = 'YYUtility/Classes/Utils/*'
    s.public_header_files = 'YYUtility/Classes/Utils/*.{h}'
  end
  
  s.swift_version = ['5.1', '5.2']
  
  s.frameworks = 'Foundation', 'UIKit'
  s.libraries = 'c++', 'bz2', 'z'
end
