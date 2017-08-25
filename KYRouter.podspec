Pod::Spec.new do |s|
s.name         = "KYRouter"
s.summary      = "一个高效,灵活,易用 的 iOS URL Router."
s.version      = '1.0.1'
s.homepage     = "https://github.com/kingly09/KYRouter"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author       = { "kingly" => "libintm@163.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/kingly09/KYRouter.git", :tag => s.version.to_s }
s.social_media_url   = "https://github.com/kingly09"
s.source_files = 'Libs/*.{h,m}'
s.framework    = "UIKit"
s.requires_arc = true
end
