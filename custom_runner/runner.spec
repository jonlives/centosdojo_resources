Summary: CentOS Dojo Runner.
Name: centosdojo-runner
Version: 0.1
Release: 1
Packager: Jon Cowie <jcowie@etsy.com>
License: MIT

%description
Package for installing the CentOS Dojo runner.

%install
# Create the directory hierarchy for building our RPM.
echo %{buildroot}
mkdir -p %{buildroot}/opt/centosdojo/custom_runner
# Copy whichever files that RPM will contain into it.
install  --mode=0755 %{centosdojo_root}/custom_runner/runner.rb %{buildroot}/opt/centosdojo

%files
/opt/centosdojo/runner.rb

%clean
rm -rf %{buildroot}
cp %{_rpmdir}/%{_arch}/centosdojo-runner*.rpm %{centosdojo_root}/rpms
