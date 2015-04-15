Pod::Spec.new do |s|
  s.name = 'Buckets'
  s.version = '1.0.1'
  s.summary = 'Swift Collection Data Structures Library'
  s.license = 'MIT'
  s.homepage = 'https://github.com/mauriciosantos/Buckets-Swift'
  s.authors = { 'Mauricio Santos' => 'mauriciosantoss@gmail.com' }
  s.source = { :git => 'https://github.com/mauriciosantos/Buckets-Swift.git', :tag => s.version }
  
  s.documentation_url = 'http://mauriciosantos.github.io/Buckets-Swift/Structs.html'
  
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.frameworks = 'Accelerate'

  s.source_files = 'Source/*.swift'
  s.requires_arc = true
end