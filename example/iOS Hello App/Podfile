# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/mimikgit/cocoapod-edge-specs.git'

target 'example_microservice_app' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for example_microservice_app
  pod 'edgeSDK-iOS', '2.0.2'
  pod 'edgeSDK-iOS-app-auth', '2.0.1'
  pod 'edgeSDK-iOS-app-ops', '2.0.1'
  pod 'Alamofire'
  pod 'JWTDecode'
  pod 'SwiftyJSON'

  # ignore all warnings from all pods
  inhibit_all_warnings!
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['ENABLE_BITCODE'] = 'YES'
              config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
              config.build_settings['VALID_ARCHS'] = '$(ARCHS_STANDARD_64_BIT)'
              config.build_settings['SWIFT_VERSION'] = '5.0'
          end
      end
  end
end
