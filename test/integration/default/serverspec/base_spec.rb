require 'spec_helper'

describe file('/tmp/kitchen/cache/stuff-1.0.x86_64.rpm') do
  it { should exist }
end
