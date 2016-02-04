Pod::Spec.new do |s|
  s.name = 'Buckets'
  s.version = '1.2.0'
  s.summary = 'Swift Collection Data Structures Library'
  s.license = 'MIT'
  s.homepage = 'https://github.com/mauriciosantos/Buckets-Swift'
  s.authors = { 'Mauricio Santos' => 'mauriciosantoss@gmail.com' }
  s.source = { :git => 'https://github.com/mauriciosantos/Buckets-Swift.git', :tag => s.version }
  
  s.documentation_url = 'http://mauriciosantos.github.io/Buckets-Swift/index.html'
  
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.frameworks = 'Accelerate'

  s.source_files = 'Source/*.swift'
  s.requires_arc = true
end