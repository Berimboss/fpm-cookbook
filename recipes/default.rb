package 'bzip2'
directory '/tmp/test'
directory '/tmp/testing'
file '/tmp/test/stuff' do
  content 'there is stuff here'
end
file '/tmp/testing/stuff' do
  content 'the itesting stuff is here'
end
fpm 'stuff' do
  sources ['/tmp/test/', '/tmp/testing/']
end
