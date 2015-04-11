Pod::Spec.new do |s|
  s.name = 'Buckets'
  s.version = '0.1.1'
  s.summary = 'Complete, tested and documented data structure library in Swift'
  s.license = 'MIT'
  s.homepage = 'https://github.com/mauriciosantos/Buckets-Swift'
  s.authors = { 'Mauricio Santos' => 'mauriciosantoss@gmail.com' }
  s.source = { :git => 'https://github.com/mauriciosantos/Buckets-Swift.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Source/*.swift'
  s.requires_arc = true
end