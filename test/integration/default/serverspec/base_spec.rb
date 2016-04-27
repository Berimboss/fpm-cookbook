require 'spec_helper'

describe file('/tmp/stuff.rpm') do
  it { should exist }
end
