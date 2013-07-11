bootloader --location=mbr --append="toram"
clearpart --all
firstboot --disabled
install
lang en_US.UTF-8
network --bootproto dhcp --device eth0 --onboot yes
part / --fstype=ext4 --size=2048
reboot
zerombr

#
# Cent 6 Repos to use when backing a new image
#

repo --name=a-base    --baseurl=http://www.mirrorservice.org/sites/mirror.centos.org/6/os/$basearch
repo --name=a-updates --baseurl=http://www.mirrorservice.org/sites/mirror.centos.org/6/updates/$basearch
repo --name=a-live    --baseurl=http://www.nanotechnologies.qc.ca/propos/linux/centos-live/$basearch/live
repo --name=a-epel    --baseurl=http://mirror.rit.edu/epel/6/$basearch
repo --name=sledgehammer --baseurl=file:///root/rpms

#
# All the packages our image contains
#
%packages
system-config-firewall-base
patch
bash
kernel
syslinux
passwd
policycoreutils
chkconfig
authconfig
rootfiles
comps-extras
xkeyboard-config
system-config-firewall-base
vim-minimal
dhclient
curl
ruby
centosdojo-runner


%post

cat > /etc/fstab << END 
tmpfs      /         tmpfs   defaults         0 0
devpts     /dev/pts  devpts  gid=5,mode=620   0 0
tmpfs      /dev/shm  tmpfs   defaults         0 0
proc       /proc     proc    defaults         0 0
sysfs      /sys      sysfs   defaults         0 0
END

#
# Force enable networking and configure for DHCP
#
echo "Force enable networking"
cat > /etc/sysconfig/network << EOF_networking
NETWORKING=yes
EOF_networking

echo "Force networking config"
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF_ifcfg
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
EOF_ifcfg


#
# Set up TTYs to run our custom runner on tty1, but keep the other TTYs as a normal shell for debugging etc.
#
echo "Modify start-ttys.conf"
cat > /etc/init/start-ttys.conf  << END_ttys
start on stopped rc RUNLEVEL=[2345]

env ACTIVE_CONSOLES=/dev/tty[1-6]
env X_TTY=/dev/tty1
task
script
    . /etc/sysconfig/init
    for tty in \$(echo \$ACTIVE_CONSOLES) ; do
          [ \"\$RUNLEVEL\" = \"5\" -a \"\$tty\" = \"\$X_TTY\" ] && continue
            if [ \"\$tty\" == \"\/dev/tty1\" ]
            then
                initctl start centosdojo TTY=\$tty
            else
                initctl start tty TTY=\$tty
            fi
    done
end script
END_ttys

echo "Create CentOS Dojo init job"
echo "stop on runlevel [012456]
exec /usr/bin/openvt -c 1 -w -f -- /opt/centosdojo/runner.rb" > /etc/init/centosdojo.conf


#
# Dracut stuff to load the root FS into memory. Patch is Base64 encoded to avoid having to escape all the characters :p
# I've included the decoded version in the email containing these scripts for convenience!
#


# The patch is base64 encoded to avoid having to escape it manually.
cat > /root/dmsquash-live-root.base64 << EOF_patch
MjFhMjIKPiBnZXRhcmcgdG9yYW0gJiYgdG9yYW09InllcyIKMTM0YzEzNSwxMzgKPCAgICAgZG9f
bGl2ZV9mcm9tX2Jhc2VfbG9vcAotLS0KPiAgICAgIyBDcmVhdGUgb3ZlcmxheSBvbmx5IGlmIHRv
cmFtIGlzIG5vdCBzZXQKPiAgICAgaWYgWyAteiAiJHRvcmFtIiBdIDsgdGhlbgo+ICAgICAgICAg
ZG9fbGl2ZV9mcm9tX2Jhc2VfbG9vcAo+ICAgICBmaQoxNjNjMTY3LDIxMwo8ICAgICBkb19saXZl
X2Zyb21fYmFzZV9sb29wCi0tLQo+ICAgICAjIENyZWF0ZSBvdmVybGF5IG9ubHkgaWYgdG9yYW0g
aXMgbm90IHNldAo+ICAgICBpZiBbIC16ICIkdG9yYW0iIF0gOyB0aGVuCj4gICAgICAgICBkb19s
aXZlX2Zyb21fYmFzZV9sb29wCj4gICAgIGZpCj4gZmkKPiAKPiAjIEkgdGhlIGtlcm5lbCBwYXJh
bWV0ZXIgdG9yYW0gaXMgc2V0LCBjcmVhdGUgYSB0bXBmcyBkZXZpY2UgYW5kIGNvcHkgdGhlIAo+
ICMgZmlsZXN5c3RlbSB0byBpdC4gQ29udGludWUgdGhlIGJvb3QgcHJvY2VzcyB3aXRoIHRoaXMg
dG1wZnMgZGV2aWNlIGFzCj4gIyBhIHdyaXRhYmxlIHJvb3QgZGV2aWNlLgo+IGlmIFsgLW4gIiR0
b3JhbSIgXSA7IHRoZW4KPiAgICAgYmxvY2tzPSQoIGJsb2NrZGV2IC0tZ2V0c3ogJEJBU0VfTE9P
UERFViApCj4gCj4gICAgIGVjaG8gIkNyZWF0ZSB0bXBmcyAoJGJsb2NrcyBibG9ja3MpIGZvciB0
aGUgcm9vdCBmaWxlc3lzdGVtLi4uIgo+ICAgICBta2RpciAtcCAvaW1hZ2UKPiAgICAgbW91bnQg
LW4gLXQgdG1wZnMgLW8gbnJfYmxvY2tzPSRibG9ja3MgdG1wZnMgL2ltYWdlCj4gCj4gICAgIGVj
aG8gIkNvcHkgZmlsZXN5c3RlbSBpbWFnZSB0byB0bXBmcy4uLiAodGhpcyBtYXkgdGFrZSBhIGZl
dyBtaW51dGVzKSIKPiAgICAgZGQgaWY9JEJBU0VfTE9PUERFViBvZj0vaW1hZ2Uvcm9vdGZzLmlt
Zwo+IAo+ICAgICBST09URlNfTE9PUERFVj0kKCBsb3NldHVwIC1mICkKPiAgICAgZWNobyAiQ3Jl
YXRlIGxvb3AgZGV2aWNlIGZvciB0aGUgcm9vdCBmaWxlc3lzdGVtOiAkUk9PVEZTX0xPT1BERVYi
Cj4gICAgIGxvc2V0dXAgJFJPT1RGU19MT09QREVWIC9pbWFnZS9yb290ZnMuaW1nCj4gCj4gICAg
IGVjaG8gIkl0J3MgdGltZSB0byBjbGVhbiB1cC4uICIKPiAKPiAgICAgZWNobyAiID4gVW1vdW50
aW5nIGltYWdlcyIKPiAgICAgdW1vdW50IC1sIC9pbWFnZQo+ICAgICB1bW91bnQgLWwgL2Rldi8u
aW5pdHJhbWZzL2xpdmUKPiAKPiAgICAgZWNobyAiID4gRGV0YWNoICRPU01JTl9MT09QREVWIgo+
ICAgICBsb3NldHVwIC1kICRPU01JTl9MT09QREVWCj4gCj4gICAgIGVjaG8gIiA+IERldGFjaCAk
T1NNSU5fU1FVQVNIRURfTE9PUERFViIKPiAgICAgbG9zZXR1cCAtZCAkT1NNSU5fU1FVQVNIRURf
TE9PUERFVgo+ICAgICAKPiAgICAgZWNobyAiID4gRGV0YWNoICRCQVNFX0xPT1BERVYiCj4gICAg
IGxvc2V0dXAgLWQgJEJBU0VfTE9PUERFVgo+ICAgICAKPiAgICAgZWNobyAiID4gRGV0YWNoICRT
UVVBU0hFRF9MT09QREVWIgo+ICAgICBsb3NldHVwIC1kICRTUVVBU0hFRF9MT09QREVWCj4gCj4g
ICAgIGVjaG8gIlJvb3QgZmlsZXN5c3RlbSBpcyBub3cgb24gJFJPT1RGU19MT09QREVWLiIKPiAg
ICAgZWNobwo+IAo+ICAgICBsbiAtcyAkUk9PVEZTX0xPT1BERVYgL2Rldi9yb290Cj4gICAgIHBy
aW50ZiAnL2Jpbi9tb3VudCAtbyBydyAlcyAlc1xuJyAiJFJPT1RGU19MT09QREVWIiAiJE5FV1JP
T1QiID4gL21vdW50LzAxLSQkLWxpdmUuc2gKPiAgICAgZXhpdCAwCjE2OWMyMTksMjIxCjwgICAg
IGVjaG8gIjAgJCggYmxvY2tkZXYgLS1nZXRzeiAkQkFTRV9MT09QREVWICkgc25hcHNob3QgJEJB
U0VfTE9PUERFViAkT1NNSU5fTE9PUERFViBwIDgiIHwgZG1zZXR1cCBjcmVhdGUgLS1yZWFkb25s
eSBsaXZlLW9zaW1nLW1pbgotLS0KPiAgICAgaWYgWyAteiAiJHRvcmFtIiBdIDsgdGhlbgo+ICAg
ICAgICAgZWNobyAiMCAkKCBibG9ja2RldiAtLWdldHN6ICRCQVNFX0xPT1BERVYgKSBzbmFwc2hv
dCAkQkFTRV9MT09QREVWICRPU01JTl9MT09QREVWIHAgOCIgfCBkbXNldHVwIGNyZWF0ZSAtLXJl
YWRvbmx5IGxpdmUtb3NpbWctbWluCj4gICAgIGZpCg==
EOF_patch

cat /root/dmsquash-live-root.base64 | base64 -d > /root/dmsquash-live-root.patch

patch /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root /root/dmsquash-live-root.patch

ls /lib/modules | while read kernel; do
  echo " > Update initramfs for kernel ${kernel}"
  initrdfile="/boot/initramfs-${kernel}.img"

  /sbin/dracut -f $initrdfile $kernel
done
%end

%post --nochroot
for rhgbfile in EFI/boot/isolinux.cfg EFI/boot/grub.conf isolinux/isolinux.cfg EFI/boot/boot.conf
do
 echo "# uglifying $LIVE_ROOT/$rhgbfile"
 echo "# uglifying $LIVE_ROOT/$rhgbfile" >> $LIVE_ROOT/$rhgbfile
 sed -i -e's/ rhgb//g' -e's/ quiet//g' -e's/ rd_NO_DM/ 3/g' $LIVE_ROOT/$rhgbfile
 echo "# uglified $LIVE_ROOT/$rhgbfile" >> $LIVE_ROOT/$rhgbfile
done

echo "Copy initramfs outside the chroot:"
ls $INSTALL_ROOT/lib/modules | while read kernel; do
  src="$INSTALL_ROOT/boot/initramfs-${kernel}.img"
  dst="$LIVE_ROOT/isolinux/initrd0.img"
  echo " > $src -> $dst"
  cp -f $src $dst
done
%end
