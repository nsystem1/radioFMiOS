# Uncomment this line to define a global platform for your project
use_frameworks!
platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'fm100' do
	pod 'KGFloatingDrawer', '~> 0.2.0'
    pod 'SwiftyJSON'
    pod 'UIColor_Hex_Swift', '~> 2.1'
    pod 'Alamofire', '~> 3.4'
    pod 'Kingfisher', '~> 2.4'
    pod 'SwiftyXMLParser', :git => 'https://github.com/yahoojapan/SwiftyXMLParser.git'
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'FacebookShare'
    pod 'Firebase'
    pod 'GRDB.swift', '~> 0.81.0'
    pod 'Fabric'
    pod 'Crashlytics'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
