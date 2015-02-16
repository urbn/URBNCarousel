#
# Be sure to run `pod lib lint URBNCarousel.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'URBNCarousel'
  s.version          = '0.8.5'
  s.summary          = 'URBNCarousel is meant to be a convenience wrapper around UICollectionView / UITableView data management'
  s.homepage         = 'https://github.com/urbn/URBNCarousel'
  s.license          = 'MIT'
  s.author           = 'URBN Application Engineering Team'
  s.source           = { :git => "https://github.com/urbn/URBNCarousel.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
end
