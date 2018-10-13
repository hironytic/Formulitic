#
# Be sure to run `pod lib lint Eventitic.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Formulitic"
  s.version          = "0.3.0"
  s.summary          = "Formula parser and evaluator"

  s.description      = <<-DESC
                       This pod provides a library for parsing formulae and evaluating them.
                       DESC

  s.homepage         = "https://github.com/hironytic/Formulitic"
  s.license          = 'MIT'
  s.author           = { "Hironori Ichimiya" => "hiron@hironytic.com" }
  s.source           = { :git => "https://github.com/hironytic/Formulitic.git", :tag => "v#{s.version}" }

  s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.9"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"
  s.requires_arc = true

  s.source_files = 'Sources/**/*'
end
