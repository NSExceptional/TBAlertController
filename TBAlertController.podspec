# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html

Pod::Spec.new do |s|
  s.name             = "TBAlertController"
  s.version          = "1.0.0"
  s.summary          = "Build UIAlertControllers with ease"
  s.homepage         = "https://github.com/NSExceptional/TBAlertController"
  s.license          = 'MIT'
  s.author           = { "Tanner Bennett" => "tannerbennett@me.com" }
  s.source           = { :git => "https://github.com/NSExceptional/TBAlertController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/NSExceptional'

  s.platform      = :ios, '12.0'
  s.swift_version = '5.3'
  
  s.source_files = 'Classes'
  s.public_header_files = 'Classes/*.h'
  s.frameworks = 'UIKit'
end
