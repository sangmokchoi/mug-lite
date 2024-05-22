# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'

target 'Mug-Lite' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Mug-Lite
  pod "YoutubePlayer-in-WKWebView", "~> 0.3.0"
  pod 'OHCubeView' # Instagram story slide function
  pod 'Google-Mobile-Ads-SDK' # Mobile ads google

  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseAnalytics'
  pod 'FirebaseUI'
  pod 'FirebaseUI/Auth'
  pod 'Firebase/Core'
  pod 'FirebaseUI/Google'
  pod 'GoogleSignIn'
#  pod 'FBAudienceNetwork'
#  pod 'GoogleMobileAdsMediationFacebook'
#  pod 'FBSDKCoreKit'
#  pod 'FBSDKLoginKit'
#  pod 'FBSDKShareKit'
  
  post_install do |installer|
      installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
                 end
            end
     end
  end
end
