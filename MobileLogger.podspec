Pod::Spec.new do |s|
  s.name             = 'MobileLogger'
  s.version          = '1.0.0'
  s.summary          = 'Logging framework for mobile applications.'
  s.description      = 'MobileLogger provides structured logging with multiple outputs.'
  s.homepage         = 'https://github.com/muhittincamdali/MobileLogger'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/MobileLogger.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
end
