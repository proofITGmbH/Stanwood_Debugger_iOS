Pod::Spec.new do |s|
  s.name             = 'StanwoodDebugger'
  s.version          = '0.2.1'
  s.summary          = 'Stanwood debugger provide live view debugging'
  s.description      = <<-DESC
    Live debugger for:
        1. Analytics
        2. UITesting views and keys [WIP]
        3. General logger [WIP]
        4. Networking [WIP]
        5. Errors [WIP]
                       DESC

  s.homepage         = 'https://github.com/stanwood/Stanwood_Debugger_iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'stanwood' => 'ios.frameworks@stanwood.io' }
  s.source           = { :git => 'https://github.com/stanwood/Stanwood_Debugger_iOS.git', :tag => s.version.to_s }
  
  s.swift_version = '4.2'
  s.ios.deployment_target = '10.0'

  s.source_files = [
    'StanwoodDebugger/Controller/**/*',
    'StanwoodDebugger/Views/**/*',
    'StanwoodDebugger/Modules/**/*',
    'StanwoodDebugger/Model/**/*',
    'StanwoodDebugger/Protocols/**/*',
    'StanwoodDebugger/Extensions/**/*'
  ]
  s.resource_bundles = {
      'StanwoodDebugger' => [
      'StanwoodDebugger/Assets/*',
      'StanwoodDebugger/Resources/*',
      'StanwoodDebugger/Views/**/*.xib',
      'StanwoodDebugger/Modules/**/*.xib'
      ]
  }

#  s.dependency 'Pulsator' /// Wait for Swift 4.2 support
  s.dependency 'StanwoodCore', '~> 1.4.1'
end
