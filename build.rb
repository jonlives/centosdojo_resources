#!/usr/bin/env ruby
# encoding: utf-8

puts ""
puts "Builder starting..."
puts ""


# Install build dependencies
puts ""
puts "Installing build dependancy packages (will prompt for sudo password)"
system "sudo yum install rpm-build"

# Build sledgehammer runner (which gets baked into the image)
puts "Building custom runner RPM"
system "rpmbuild --define 'centosdojo_root /root' -ba custom_runner/runner.spec"

# END SLEDGEHAMMER SPECIFIC


# Run "createrepo" on our directory of RPMs which we use in addition to Cent Repos
puts ""
puts "Refreshing local RPM repo"
system "createrepo rpms"

# Install dependencies
puts ""
puts "Installing Livetools dependancy packages (will prompt for sudo password)"
system "sudo yum install syslinux syslinux-extlinux anaconda-runtime"

# Installed patched livecd-tools and python-imgcreate to work with newer CentOS versions
puts ""
puts "Installing patched livecd-toold and python-imgcreate"
system "sudo rpm -i rpms/livecd-tools-13.4-1.el6.x86_64.rpm rpms/python-imgcreate-13.4-1.el6.x86_64.rpm"

# Build ISO from sledgehammer.ks
puts ""
puts "Building ISO from centosdojo.ks"
system "sudo LANG=C livecd-creator --config=centosdojo.ks --fslabel=centosdojo"

if !File.exists?("./centosdojo.iso")
  puts "ERROR: ISO creation failed. Aborting..."
  exit 1
end

# Convert ISO image to PXE format so that we can netboot it in cobbler
puts ""
puts "Converting ISO to PXE Image"
system "sudo livecd-iso-to-pxeboot centosdojo.iso"

puts ""
puts "Compressing PXE Image"
system "tar -zcvf tftpboot.tar.gz tftpboot"

puts ""
puts "Cleaning up..."
system "sudo rm -rf tftpboot centosdojo *.rpm"

puts ""
puts "tftpboot.tar.gz can now be copied to your cobbler server."