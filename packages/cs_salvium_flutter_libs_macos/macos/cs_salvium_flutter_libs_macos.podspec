#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cs_salvium_flutter_libs_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cs_salvium_flutter_libs_macos'
  s.version          = '0.0.1'
  s.summary          = 'Binaries required to use cs_salvium in a Flutter project'
  s.description      = <<-DESC
Binaries required to use cs_salvium in a Flutter project
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.vendored_frameworks = 'Frameworks/SalviumWallet.framework'
  
  # Prepare command to handle codesigning at build time
  s.prepare_command = <<-CMD
    # Remove symlinks temporarily for codesigning
    rm -f "Frameworks/SalviumWallet.framework/SalviumWallet"
    rm -f "Frameworks/SalviumWallet.framework/MacOS"
    rm -f "Frameworks/SalviumWallet.framework/Resources"
    
    # Sign the framework
    echo "Signing SalviumWallet.framework..."
    codesign --force --sign - "Frameworks/SalviumWallet.framework"
    
    # Restore symlinks after signing
    ln -sf Versions/A/MacOS/SalviumWallet "Frameworks/SalviumWallet.framework/SalviumWallet"
    ln -sf Versions/Current/MacOS "Frameworks/SalviumWallet.framework/MacOS"
    ln -sf Versions/Current/Resources "Frameworks/SalviumWallet.framework/Resources"
  CMD
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'FRAMEWORK_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/Frameworks',
    'OTHER_LDFLAGS' => '-framework "SalviumWallet"'
  }
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.swift_version = '5.0'
end
