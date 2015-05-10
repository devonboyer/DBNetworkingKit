#
# Be sure to run `pod lib lint DBNetworkingKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DBNetworkingKit"
  s.version          = "0.0.1"
  s.summary          = "A short description of DBNetworkingKit."
  s.description      = <<-DESC
                       An optional longer description of DBNetworkingKit

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
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
