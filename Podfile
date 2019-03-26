# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

workspace 'SmartLibrary'
  
def my_pods
  # Pods for SmartLibrary
  pod 'SwiftKeychainWrapper'
  pod 'SVProgressHUD', '~> 2.2'
  pod 'AlamofireNetworkActivityLogger', '~> 2.0'
  # Pods for ContentComponent
  pod 'Alamofire', '4.8.1'
  pod 'Kingfisher', '~> 5.1'
end 
  
target 'SmartLibrary' do
  inherit! :search_paths
  my_pods
end

target 'SmartLibrary_Staging' do
  inherit! :search_paths
  my_pods
end

target 'SmartLibraryTests' do
  inherit! :search_paths
  # Pods for testing
end

