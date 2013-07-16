#
# Author:: Joe Williams (<j@boundary.com>)
# Cookbook Name:: bprobe
# Recipe:: dependencies
#
# Copyright 2011, Boundary
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node[:platform_family]
when "rhel"

  yum_key "RPM-GPG-KEY-boundary" do
    url "https://yum.boundary.com/RPM-GPG-KEY-Boundary"
    action :add
  end

  # default to 64bit
  machine = "x86_64"

  case node[:kernel][:machine]
  when "x86_64"
    machine = "x86_64"
  when "i686"
    machine = "i386"
  when "i386"
    machine = "i386"
  end

  rhel_platform_version = node[:platform] == "amazon" ? "6" : node[:platform_version]

  yum_repository "boundary" do
    description "boundary"
    url "https://yum.boundary.com/centos/os/#{rhel_platform_version}/#{machine}/"
    key "RPM-GPG-KEY-boundary"
    action :add
  end

  ruby_block "reload-internal-yum-cache" do
    block do
      Chef::Provider::Package::Yum::YumCache.instance.reload
    end
  end

when "debian"

  package "apt-transport-https"

  apt_repository "boundary" do
    uri "https://apt.boundary.com/ubuntu/"
    # precise is the latest version supported by the boundary repo,
    # so force later versions (quantal and raring) to use that
    distribution "precise"
    components ["universe"]
    key "https://apt.boundary.com/APT-GPG-KEY-Boundary"
    action :add
  end
end

cookbook_file "#{Chef::Config[:file_cache_path]}/cacert.pem" do
  source "cacert.pem"
  mode 0600
  owner "root"
  group "root"
end
