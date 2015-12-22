Pod::Spec.new do |s|
  s.name         = "UIView+draggable"
  s.version      = "1.0.3"
  s.summary      = "UIView category that adds dragging capabilities"
  s.homepage     = "https://github.com/andreamazz/UIView-draggable"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Andrea Mazzini" => "andrea.mazzini@gmail.com" }
  s.source       = { :git => "https://github.com/andreamazz/UIView-draggable.git", :tag => s.version }
  s.platform     = :ios, '7.0'
  s.source_files = 'Source', '*.{h,m}'
  s.requires_arc = true
  s.social_media_url = 'https://twitter.com/theandreamazz'
end
