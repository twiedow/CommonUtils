Pod::Spec.new do |s|
  s.name         = "CommonUtils"
  s.version      = "0.0.1"
  s.summary      = "Library with utilities for common jobs."

  s.homepage     = "https://github.com/twiedow/CommonUtils"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Tobias Wiedow" => "tobi@wiedow.biz" }

 	s.platform     = :ios
  s.source       = { :git => "https://github.com/twiedow/CommonUtils.git", :tag => "0.0.1" }
  s.source_files  = 'CommonUtils/Classes', 'CommonUtils/Classes/**/*.{h,m}'
  s.requires_arc = true
end
