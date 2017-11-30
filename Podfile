source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!
#==================================================================================================
target 'RussianBills' do
    pod ‘Alamofire’, :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'master'
    pod ‘RealmSwift’, :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'master'
    pod ‘SwiftyJSON’
    pod 'Kanna', :git => 'https://github.com/tid-kijyun/Kanna.git', :branch => 'feature/v4.0.0'
    pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'master'
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'RxSwift'
    pod 'RxRealm'
    pod 'RxCocoa'
end
#==================================================================================================
target 'RusBillsTodayExtension' do
    pod ‘RealmSwift’, :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'master'
    pod ‘SwiftyJSON’
end
#==================================================================================================
target 'RusBillsIMessageExtension' do
    pod ‘RealmSwift’, :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'master'
    pod ‘SwiftyJSON’
end
#==================================================================================================
post_install do |installer|
    installer.aggregate_targets.each do |target|
        copy_pods_resources_path = "Pods/Target Support Files/#{target.name}/#{target.name}-resources.sh"
        string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
        assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
        text = File.read(copy_pods_resources_path)
        new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
        File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
    end
end