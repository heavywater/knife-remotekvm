$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'knife-remotekvm/version'
Gem::Specification.new do |s|
  s.name = 'knife-remotekvm'
  s.version = KnifeRemoteKVM::VERSION.version
  s.summary = 'Create KVM nodes'
  s.author = 'Chris Roberts'
  s.email = 'chrisroberts.code@gmail.com'
  s.homepage = 'http://github.com/heavywater/knife-remotekvm'
  s.description = "Remote KVM"
  s.require_path = 'lib'
  s.files = Dir.glob('**/*')
  s.add_dependency 'chef'
end
