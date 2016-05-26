require 'poise'
require 'chef/resource'
require 'chef/provider'

module Fpm
  class Resource < Chef::Resource
    include Poise
    provides  :fpm
    actions   :package
    attribute :install_deps, default: true, kind_of: [TrueClass, FalseClass]
    attribute :name, name_attribute: true, kind_of: String
    attribute :sources, required: true, kind_of: String
    attribute :ruby_version, kind_of: String, default: '2.1.2', regex: ['2.1.2']
    attribute :input_type, kind_of: String, default: 'dir', regex: 'dir'
    attribute :output_type, kind_of: String, default: 'rpm', regex: ['rpm', 'deb']
    attribute :output_dir, kind_of: String, default: "#{Chef::Config[:file_cache_path]}", required: true
    attribute :package_version, kind_of: String, default: '1.0'
  end
  class Provider < Chef::Provider
    include Poise
    provides :fpm
    def output_format(name, ext='rpm', arch='x86_64', version='1.0')
      ::File.join(name, version, "-1.#{arch}, #{ext}")
    end
    def output_name(name)
      self.output_format(name)
    end
    def virtual_ruby(version, gems=[])
      include_recipe 'rbenv'
      include_recipe 'rbenv::ruby_build'
      rbenv_ruby version
      gems.each do |gem|
        rbenv_gem gem do
          ruby_version version
        end
      end
    end
    def deps
      package 'rpm-build'
      package 'xz'
      package 'xz-devel'
    end
    def bin
      "/opt/rbenv/versions/#{new_resource.ruby_version}/bin/fpm"
    end
    def pkg(input_type, output_type, output_name, name, sources)
      directory new_resource.output_dir do
        recursive true
      end
      bash "package #{name}" do
        cwd Chef::Config[:file_cache_path]
        code <<-EOH
        #{self.bin} -s #{input_type} -t #{output_type} -n #{name} #{sources}
        mv #{::File.join(output_name, resource.output_dir, name, ".#{output_type}")}
        EOH
        not_if do ::File.exists?(::File.join(new_resource.output_dir, name, ".#{output_type}")) end
      end
    end
    def given_the_givens
      virtual_ruby new_resource.ruby_version, ['fpm']
      if new_resource.install_deps
        deps
      end
      yield
    end
    def action_package
      given_the_givens do
        self.pkg(new_resource.input_type, new_resource.output_type, self.output_name(new_resource.name), new_resource.name, new_resource.sources)
      end
    end
  end
end
