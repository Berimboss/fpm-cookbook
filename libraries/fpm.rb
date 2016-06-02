require 'poise'
require 'chef/resource'
require 'chef/provider'

module Fpm
  class Resource < Chef::Resource
    include Poise
    provides  :fpm
    actions   :package
    attribute :name, name_attribute: true, kind_of: String
    attribute :user, default: 'root'
    attribute :group, default: 'root'
    attribute :mode, default: 0777
    attribute :install_deps, default: true, kind_of: [TrueClass, FalseClass]
    attribute :sources, required: true, kind_of: Array
    attribute :ruby_version, kind_of: String, default: '2.1.2', regex: ['2.1.2']
    attribute :input_type, kind_of: String, default: 'dir', regex: 'dir'
    attribute :output_type, kind_of: String, default: 'rpm', regex: ['rpm', 'deb']
    attribute :output_dir, kind_of: String, default: "#{Chef::Config[:file_cache_path]}", required: true
    attribute :package_version, kind_of: String, default: '1.0'
    attribute :template_stub, default: 'fpm.erb'
  end
  class Provider < Chef::Provider
    include Poise
    provides :fpm
    def menu
      {
        :items => [
          {:symbol => '-t', :input => 'OUTPUT_TYPE', :description => 'the type of package you want to create (deb, rpm, solaris, etc)', :type => "String"},
          {:symbol => '-s', :input => 'INPUT_TYPE', :description => 'the package type to use as input (gem, rpm, python, etc)', :type => "String"},
          {:symbol => '-C', :input => 'CHDIR', :description => 'Change directory to here before searching for files', :type => "String"},
          {:symbol => '--prefix', :input => 'PREFIX', :description => 'A path to prefix files with when building the target package. This may be necessary for all input packages. For example the gem type will prefix with your gem directory automatically', :type => "String"},
          {:symbol => '-p', :input => 'OUTPUT', :description => 'The package file path to output', :type => "String"},
          {:symbol => '-f', :input => 'FORCE', :description => 'Force output even if it will overwrite an existing file', :type => "BOOL", default: true},
          {:symbol => '-n', :input => 'NAME', :description => 'The name to give to the package', :type => "String"},
          {:symbol => '--log', :input => 'LOG', :description => 'Set the log level, Values: error, warn, info, debug', :type => "String", :possibles => %w{error warn info debug}},
          {:symbol => '--verbose', :input => 'VERBOSE', :description => 'Enable verbose output', :type => "String", default: false},
          {:symbol => '--debug', :input => 'DEBUG', :description => 'Enable debug output', :type => "String"},
          {:symbol => '--debug-workspace', :input => 'DEBUGWORKSPACE', :description => 'Keep any file workspaces around for debugging', :type => "String"},
          {:symbol => '-v', :input => 'VERSION', :description => 'The version to give to the package', :type => "String", default: '1.0'},
          {:symbol => '--iteration', :input => 'ITERATION', :description => 'The iteration to give to the package. RPM calls this the release.', :type => "String"},
          {:symbol => '--epoch', :input => 'EPOCH', :description => 'The epoch value for this package. RPM and debian calls this epoch', :type => "String"},
          {:symbol => '--license', :input => 'LICENSE', :description => '(optional) license name for this package', :type => "String"},
          {:symbol => '--vendor', :input => 'VENDOR', :description => '(optional) vendor name for this package', :type => "String"},
          {:symbol => '--category', :input => 'CATEGORY', :description => '(optional) category this package belongs to', :type => "String", default: 'none'},
          {:symbol => '-d', :input => 'DEPENDENCY', :description => 'a dependency. this flag can be specified multiple times', :type => "String", default: 'none'},
          {:symbol => '--no-depends', :input => 'DEPENDENCY', :description => 'Do not list any dependencies in this package', :type => "String", default: false},
          {:symbol => '--no-auto-depends', :input => 'DEPENDENCY', :description => 'Do not list any dependencies in this package automatically', :type => "String", default: false},
          {:symbol => '--provides', :input => 'PROVIDES', :description => 'What this package provides, can be specified multiple times', :type => "String", default: false},
          {:symbol => '--conflicts', :input => 'CONFLICTS', :description => 'Other packages/versions this package conflicts with, this flag can be specified multiple times', :type => "String", default: false},
          {:symbol => '--replaces', :input => 'REPLACES', :description => 'Other packages/versions this package replaces. this flag can be specified multiple times', :type => "String", default: false},
          {:symbol => '--config-files', :input => 'CONFIG_FILES', :description => 'Mark a file in the package as being a config file. can be multiple and directory recursive', :type => "String", default: false},
          {:symbol => '--directories', :input => 'DIRECTORIES', :description => 'Recursively mark a directory as being owned by the package', :type => "String"},
          {:symbol => '-a', :input => 'ARCHITECTURE', :description => 'the architecture name. usually matches uname -m', :type => "String"},
          {:symbol => '-m', :input => 'MAINTAINER', :description => 'the architecture name. usually matches uname -m', :type => "String"},
          {:symbol => '-S', :input => 'PACKAGE_NAME_SUFFIX', :description => 'a name suffix to append to package and dependencies', :type => "String"},
          {:symbol => '-e', :input => 'EDIT', :description => 'Edit the package spec before building', :type => "BOOL", default: false},
          {:symbol => '-x', :input => 'EXCLUDE_PATTERN', :description => 'Exclude paths matching pattern (shell wildcard globs valid here), can be multiple', :type => "BOOL", default: false},
          {:symbol => '--description', :input => 'DESCRIPTION', :description => 'Exclude paths matching pattern (shell wildcard globs valid here), can be multiple', :type => "BOOL", default: false},
          {:symbol => '--url', :input => 'URI', :description => 'add a url for this package', :type => "BOOL", default: false},
          {:symbol => '--inputs', :input => 'INPUTS_PATH', :description => 'The path to a file containing a newline-separated list of files and dirs to use as input'},
          {:symbol => '--after-install', :input => 'FILE', :description => 'A script to be run after package installation'},
          {:symbol => '--before-install', :input => 'FILE', :description => 'A script to be run before package installation'},
          {:symbol => '--after-remove', :input => 'FILE', :description => 'A script to be run after package removal'},
          {:symbol => '--before-remove', :input => 'FILE', :description => 'A script to be run before package removal'},
          {:symbol => '--after-upgrade', :input => 'FILE', :description => 'A script to be run after package upgrade'},
          {:symbol => '--before-upgrade', :input => 'FILE', :description => 'A script to be run before package upgrade'},
          {:symbol => '--template-scripts', :input => 'FILE', :description => 'allow scripts to be templated this lets you use ERB to template your packaging scripts'},
          {:symbol => '--template-value', :input => 'KEY=VALUE', :description => 'make key avail in script templates so <%=key%> works'},
          {:symbol => '--work-dir', :input => 'KEY=VALUE', :description => 'make key avail in script templates so <%=key%> works'},
          {:symbol => '--gem-bin-path', :input => 'DIRECTORY', :description => '(gem only) The directory to install gem executables'},
          {:symbol => '--gem-package-name-prefix', :input => 'PREFIX', :description => '(gem only) The directory to install gem executables'},
          {:symbol => '--gem-gem', :input => 'PATH_TO_GEM', :description => 'The path to the gem tool'},
          {:symbol => '-h', :input => 'HELP', :description => 'The path to the gem tool'},
        ]
      }
    end
    def output_name(name, arch='x86_64', version='1.0')
      #"#{name}-#{version}-1.#{arch}.#{ext}"
      "#{name}-#{version}-1.#{arch}.#{new_resource.output_type}"
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
    def bin_options_combos
        [
          {:symbol => '-s', :value => new_resource.input_type},
          {:symbol => '-t', :value => new_resource.output_type},
          {:symbol => '-n', :value => new_resource.name},
        ]
    end
    def bin_options
        [
          {:value => ''}
        ]
    end
    def get_sources(sources)
      sources = sources.join(' ')
    end
    def interpreter
      "/opt/rbenv/versions/#{new_resource.ruby_version}/bin/ruby"
    end
    def pkg_new
      template ::File.join(new_resource.output_dir, 'do_fpm') do
        user new_resource.user
        group new_resource.group
        source new_resource.template_stub
        mode new_resource.mode
        variables :context => {
          :interpreter => self.interpreter,
          :bin => self.bin,
          :sources => self.get_sources(new_resource.sources),
          :bin_options => self.bin_options,
          :bin_options_combos => self.bin_options_combos,
        }
      end
      bash "do_fpm" do
        code "#{::File.join(new_resource.output_dir, 'do_fpm')}"
        cwd Chef::Config[:file_cache_path]
        not_if do ::File.exists?("#{::File.join(Chef::Config[:file_cache_path])}/#{"#{new_resource.name}-#{new_resource.package_version}-1.x86_64.#{new_resource.output_type}"}") end
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
        #self.pkg(new_resource.input_type, new_resource.output_type, self.output_name(new_resource.name, version=new_resource.package_version), new_resource.package_version, new_resource.name, new_resource.sources)
        self.pkg_new
      end
    end
  end
end
