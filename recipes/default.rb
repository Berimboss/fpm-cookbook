directory '/tmp/test'
directory '/tmp/test/amazing'
file '/tmp/test/stuff' do
  content 'there is stuff here'
end
file '/tmp/test/amazing/stuff' do
  content 'the amazing stuff is here'
end
fpm 'stuff' do
  sources ['/tmp/test/']
end
#package "/tmp/stuff.rpm"
