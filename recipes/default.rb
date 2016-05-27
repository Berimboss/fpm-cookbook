directory '/tmp/test'
file '/tmp/test/stuff' do
  content 'there is stuff here'
end
fpm 'stuff' do
  sources ['/tmp/test/']
end
#package "/tmp/stuff.rpm"
