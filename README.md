CentOS Dojo 2013 Resources
=====================

The resources to go with my talk "Custom Live Media Spinning" @ the CentOS Dojo 2013 in Aldershot

##Installation

The only dependency for the build script to run is Ruby, and you'll need to be running on a Redhat / CentOS / Fedora system.

##Files

* build.rb - The script to build your custom image
* centosdojo.ks - Kickstart file for the image
* custom_runner
    * runner.rb - Custom runner to be run as TTY1
    * runner.spec - Specfile to generate a runner RPM
* rpms
    * livecd-tools-13.4-1.el6.x86_64.rpm - Updated version of livecd-tools
    * python-imgcreate-13.4-1.el6.x86_64.rpm - Updated version of python-imgcreate
    * redhat-logos-60.0.14-13.el6.noarch.rpm - Tweated redhat-logos to use Etsy logo on initial boot screen

    
##Instructions

The build script, build.rb, will work mostly out of the box. You will however need to change line 16 to reflect the path from where you're running the script

For example, you might change:

```
system "rpmbuild --define 'centosdojo_root /root' -ba custom_runner/runner.spec"
```

to:

```
system "rpmbuild --define 'centosdojo_root /home/myuser' -ba custom_runner/runner.spec"
```

You'll also need to change the path in line 19 of the kickstart file to reflect the path to your rpms directory.

For example, you might change:

```
repo --name=sledgehammer --baseurl=file:///root/rpms
```

to:

```
repo --name=sledgehammer --baseurl=file:///root/rpms
```

Once you've made these changes, just run ```./build.rb``` and you should end up with the following files:

* centosdojo.iso - an ISO image you can boot from
* tftpboot.tar.gz - The PXE version of the above ISO that you can use with Cobbler