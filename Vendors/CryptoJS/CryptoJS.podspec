Pod::Spec.new do |spec|
  spec.name         = 'CryptoJS'
  spec.version      = '0.1'
  spec.license      = { :type => '' }
  spec.homepage     = 'https://github.com/wavesplatform/WavesWallet-iOS/'
  spec.authors      = { '' => '' }
  spec.summary      = 'CryptoJS'
  spec.source       = { 'path' => 'Source' }
  spec.source_files = 'Source/*.swift'
#   spec.public_header_files = 'Source/*.swift'
  spec.resources = ['JS/*.js']
end
