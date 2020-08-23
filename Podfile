# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Mp3Cutter' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Mp3Cutter

  target 'Mp3CutterTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  pod 'mobile-ffmpeg-min', '~> 4.2'
  pod 'MGSwipeTableCell'
  pod 'AudioKit/Core'
  pod 'JGProgressHUD', '~> 2.0'
  pod 'Toast-Swift'
  pod 'FDWaveformView', '~> 5.0'
#  pod 'fluid-slider'
  pod 'SnapKit', '~> 5.0.0'
  pod 'M13Checkbox', '3.2.2'
  pod 'IQKeyboardManager', '~> 6.2.0'
  
  post_install do |installer|
       installer.pods_project.targets.each do |target|
           target.new_shell_script_build_phase.shell_script = "mkdir -p $PODS_CONFIGURATION_BUILD_DIR/#{target.name}"
           if ['Toast-Swift'].include? target.name
               target.build_configurations.each do |config|
                   config.build_settings['SWIFT_VERSION'] = '4'
                   config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
               end
           end

       end
   end

  target 'Mp3CutterUITests' do
    # Pods for testing
  end

end
