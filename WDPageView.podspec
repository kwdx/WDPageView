Pod::Spec.new do |s|
  s.name          = "WDPageView"
  s.version       = "0.0.2"
  s.summary       = "A page scrolling inspired by UIScrollView"
  s.homepage      = "https://github.com/kwdx/WDPageView"
  s.license       = "MIT"
  s.author             = { "warden" => "wenduo_mail@163.com" }
  s.platform      = :ios, "9.0"
  s.source        = { :git => "https://github.com/kwdx/WDPageView.git", :tag => "#{s.version}" }
  s.source_files  = "WDPageView/*.{h,m}"
  s.frameworks    = "UIKit", "Foundation"

  s.requires_arc  = true
end
