Pod::Spec.new do |s|
  s.name             = 'ShengwangBeautyView'
  s.version          = '0.1.0'
  s.summary          = 'A beauty effects SDK for iOS with real-time video processing.'
  s.description      = <<-DESC
  ShengwangBeautyView provides real-time video beautification features including beauty filters,
  makeup effects, video filters, and stickers. Built on Agora RTC Engine for video calling
  and live streaming applications.
                       DESC

  s.homepage         = 'https://github.com/yourusername/ShengwangBeautyView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HeZhengQing' => 'your.email@example.com' }
  s.source           = { :git => '', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Classes/**/*'
  
  s.resource_bundles = {
    'BeautyView' => ['Resources/**/*']
  }

  s.frameworks = 'UIKit', 'Foundation'

  s.dependency 'AgoraRtcEngine_Special_iOS'
  # s.dependency 'AgoraRtcEngine_iOS'
  
end
