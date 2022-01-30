# Retro Disk Imaging 
This suite of PowerShell scripts are used to transfer disk images to and from 5.25" disketts using either the Commodore 1541 or Commodore 1571 disk drives.

## Requirements
ALL of these tools depend on 3rd party software, specifically OpenCBM Tools and nibtools.  All of these tools were written for Windows Powershell.
These are completely untested for Linux versions of PowerShell.

## Software Dependencies
- VICE Commdore Emulation Software - https://vice-emu.sourceforge.io/
- OpenCBM installer - https://opencbm.trikaliotis.net/opencbm-9.html (Search for Windows Installation Walk-through)
- NibTools installer - https://rittwage.com/c64pp/?pg=nibtools -- https://rittwage.com/files/nibtools/

I currently have no part in any of the above projects.

I recommend you put these software packages in your system path, or, in the directory you'll be running these scripts

## Hardware Dependencies
I've been running the testing for these on a Commodore 1571 drive.  Some functionality does not work on a 1541, but the above tools are smart enough to deal.

I'm also using a ZoomFloppy hooked into my PC using USB.

## Knowledge Transfer
### 1541
The 1541 is a single sided disk reader only.  It does not support disk nibbling.  The best it can offer is to use d64copy to copy the contents of the disk at a very basic level.  This does not get around copy protection.

### 1571
The 1571 is a dual head disk reader.  It can perform all the functions of the 1571.  Depending on the script used here, and, depending on what is being read from the disk, the tools will automatically adjust their reading.

There is no nibble reading for double sided disks as of this writing.

Nibbling disks does not offer a guarantee to correctly copy a copy protected disk.  Other tools and hardware may be required.

# FullFormat.ps1
## About
This script will prompt you to take either a D71 or D64 image and transfer it to a disk.  If using a 1571, it will look at the file extension of the image you want to transfer and format the disk accordingly prior to transferring the actual image.  Writing images to disks require disks to be formatted.  It's good practice to format the disks prior to writing the image just to make sure that things are all checking out.

### 1541 Mode
D64 images will be written to a single side of the floppy disk.

### 1571 Mode
D71 images will be written to both sides of the floppy disk.

## Use
Execute FullFormat.ps1 and the tool will ask you which image you would like to send to diskette.

# copydisk.ps1
## About
This script will take the contents of a disk and store it on your computer as a 1541 or 1571 compatible disk image.

## Notes
Although diskettes can be formatted on both sides, the 1571 can read both sides of the disk without having to 'flip' the disk.  It creates one file system and doubles the available storage.

## Use
Execute copydisk.ps1 and the script will check what kind of diskette it is reading.  If it is reading a single sided disk, it'll ask if you would like to use d64copy or nibread.

In either case of a single sided or double sided disk, the software will ask you where you'd like to store the image.
