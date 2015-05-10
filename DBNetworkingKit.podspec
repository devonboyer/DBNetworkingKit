Pod::Spec.new do |s|
  s.name             = "DBNetworkingKit"
  s.version          = "0.0.1"
  s.summary          = "A networking framework for iOS built with a modular architecture."
  s.homepage         = "https://github.com/DevonBoyer/DBNetworkingKit"
  s.license          = 'MIT'
  s.author           = { "Devon Boyer" => "devonboyer94@gmail.com" }
  s.source           = { :git => "https://github.com/DevonBoyer/DBNetworkingKit.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'DBNetworkingKit' => ['Pod/Assets/*.png']
  }
end
