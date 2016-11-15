RNC2016
=======

The reference development system is Linux Debian 8.6.0 64 bit (amd64), even though the 32 bit should work as well. But if your PC has a 64 bit CPU, please choose the 64 bit linux version.

You can download the reference images from here:

* [Debian 8.6.0, 64 bit](http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-8.6.0-amd64-cinnamon-desktop.iso)
* [Debian 8.2.0, 32 bit](http://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/debian-live-8.6.0-i386-cinnamon-desktop.iso)

There is a [short movie](http://vimeo.com/77040275) that shows the kind of results RNC will produce at the end of its development.

Suggested solution: Virtual Machine
-----------------------------------

It is suggested to install Debian under a virtual machine using [VirtualBox](http://www.virtualbox.org), which is a free software. 
Other virtualization systems (VMWare, or Parallels) can perform better, but are not free.

**Important Note N. 1**: There are a number of different disk images for the same release (8.6), some of them *do not* install everithing is needed for our sake. Consequently,
before proceeding any further, make sure that the install image you are using corresponds to the **Debian 8.6 live with Cinnamon Desktop**.

**Important Note N. 2**: Unless you have an old PC that has a 32-bit CPU (i.e. pre-Core2 Duo), it is strongly advisable to create a 64-bit virtual machine. 
On Windows platforms, this requires to enable 64-bit virtualization extensions at the BIOS level (these are usually disabled by default). 
Conversely, Mac OS X virtualization is 64-bit by default.

When creating the virtual machine select the following settings:

* Operating System: Debian 64 bit
* Disk space: >= 10 Gb
* RAM: >= 1024 Mb
* video RAM: 32 Mb, 3D acceleration
* Network: select NAT
* CD: select the virtual disk image you downloaded
* Boot order: ensure that CD comes before HD
* anything else: accept defaults

Just do a plain graphical install. **It is advised to install Debian in English language**. Be aware that for the following instructions to work, you have to be connected to the internet via a network that does not require a proxy. Your private home network and the campus WiFi networks `eduroam` and `unitn-x` should work fine (better than the `unitn` one).

**It is preferable that you perform the following installation connected to the network (either the `unitn-x` WiFi network or your home WiFi).**

0. on boot, select "graphical Install"
1. select English as language
2. select Other->Europe->Italy as location
3. select United States (en_US.UTF8) as locale
4. select your actual keyboard layout
5. freeley choose a host name, and use `dii.unitn.it` as domain
6. skip the root password field (leave it empty)
7. freely choose the new user full name (spaces allowed)
8. choose `rnc` as username (short name, case sensitive, single word). You can actually choose different short names, but in the following instructions it will assumed that the user name is `rnc`.
9. choose a reasonably safe password for the user `rnc`
10. select *Guided - use entired disk* as partitioning method, and accept defaults in the following disk set-up panes
11. wait for the installer copying data to disk
12. when asked whether to use a network mirror or not, choose *yes*
13. select *Italy*, then accept the default mirror
14. leave blank the proxy field
15. accept to install GRUB on the master boot record, and select `\dev\sda` as the bootable device
16. wait for the installation to finish and reboot the VM.

Note that VirtualBox allows you to take *snapshots* of the virtualization system: these are images of an OS at a given time, and can be used to revert to a clean state whenever something goes wrong. It is suggested that you take a snapshot immediately after the first boot, so that you can skip the installation process whenever would you need to start again from scratch.

> **NOTE**: a neat advantage of virtualization system is that the virtualized machine is actually a collection of few files that can be safely archived on an external disk, and also copied to a different host machine. For example, you could work in groups, install Debian only once and then copy the virtual machine on the laptops of the other team members, saving time.


Other solution: Dual Boot System
--------------------------------

This is the suggested way to go if you have a slow, single-core PC with less than 4 Gb of RAM. There are plenty of instructions on the Internet describing how to create a dual boot Windows/Linux install, starting from [Debian's own](http://www.debian.org/releases/stable).



Installation of prerequisites
-----------------------------

Most of the operations will be done in a terminal, or console, application. Open it from `Applications->Accessories->Terminal`.

Execute the following command for installing the needed software. Here and in the following, the first character `$` stands for the command prompt, and you *do not* have to type it:

    $ wget -qO - http://bit.ly/debian_devel2016 | sudo bash
    
This will ask for your password and take a while (~5 mins) to execute, also depending on your connection speed.

> **NOTE**: the link above has been corrected and checked. On a proper install and on a working Internet connection it works as expected.

At the end of the process, you shall see a message saying "ALL DONE!". Now type the command `ruby -v`, and if you get a message saying that
your ruby  version is `2.1.5p273` (or newer) that means you are set.


Installation of Linux Guest Additions (VirtualBox only!)
--------------------------------------------------------

On VirtualBox, it is suggested to also install the Linux Guest Additions, a set of tools and drivers that improve the user experience also enabling hardware 3D acceleration within the virtual machine. Proceed as follows:

  1. Select VirtualBox menu `Devices | Install Guest Additions...`
  2. open a terminal window
  3. type the following commands (DOUBLE-CHECK THE EXACT TYPING!):
  
          $ cd ~
          $ mkdir tmp
          $ sudo cp -r /media/cdrom/* tmp/
          $ sudo ./VBoxLinuxAdditions.run
  
  4. wait for the commands to complete, then close the terminal window and 
     reboot the virtual machine
  5. Open a terminal and type the following:
  
          $ cd ~
          $ rm -rf tmp
          

Running on Mac
--------------

Current version also runs on Mac. On OS X, Ruby comes preinstalled and there is no need to run the setup script reported above (in fact, it won't work). Nevertheless, some Ruby gems (libraries) must be installed. 

To do that, fire up a Terminal window and enter the following commands:

    $ sudo gem install gnuplot ffi --no-rdoc --no-ri
    
Additionally, you also need Gnuplot. My suggestion is to install it via [Homebrew](http://brew.sh), but prebuilt packages available on the Internet should work as well.
