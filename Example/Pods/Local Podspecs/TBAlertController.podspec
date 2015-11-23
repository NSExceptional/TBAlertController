# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html

Pod::Spec.new do |s|
  s.name             = "TBAlertController"
  s.version          = "0.1.0"
  s.summary          = "UIAlertController + UIAlertView + UIActionSheet = TBAlertController"
  s.description      = <<-DESC
                       UIAlertController, UIAlertView, and UIActionSheet unified for developers who want to support iOS 7 and 8. No more conditional code when using any of these classes!
                       DESC
  s.homepage         = "https://github.com/ThePantsThief/TBAlertController"
  s.license          = 'MIT'
  s.author           = { "Tanner Bennett" => "tannerbennett@me.com" }
  s.source           = { :git => "https://github.com/ThePantsThief/TBAlertController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ThePantsThief'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.public_header_files = 'Classes/*.h'
  s.frameworks = 'UIKit'
end
