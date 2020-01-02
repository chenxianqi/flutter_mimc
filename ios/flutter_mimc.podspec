#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_mimc.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_mimc'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'http://kf.aissz.com:666/example/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'kieth' => '361554012@qq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.libraries = 'c++'
  s.platform = :ios, '8.0'
  s.frameworks = 'CoreTelephony','SystemConfiguration'
  # 导入第三方资源库
  s.vendored_frameworks = 'Frameworks/openssl.framework','Frameworks/MIMCProtoBuffer.framework','Frameworks/MMCSDK.framework'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.ios.deployment_target = '8.0'
end
