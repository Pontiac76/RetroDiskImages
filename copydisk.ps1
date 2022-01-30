# This script will take a copy of the disk in drive 8 via OpenCBM
# The script will automatically determine if the disk being read is formatted in single-sided or double-sided format
#     and then proceed with the correct duplication method
# Note, this is NOT a nibbler.  I've confirmed from the authors of nibread that there is too much work
#     involved in modifying nibread to read double-sided disks.
#
# DEPENDENCIES
# ------------
# It's recommended to put the following applications somewhere in your systems path
#
# c1541.exe - Found in VICE Commdore Emulation Software - https://vice-emu.sourceforge.io/
# d64copy.exe - Found in OpenCBM installer - https://opencbm.trikaliotis.net/opencbm-9.html (Search for Windows Installation Walk-through)
# cbmctrl.exe - Found in OpenCBM installer
# nibread.exe - Found in NibTools installer - https://rittwage.com/c64pp/?pg=nibtools -- https://rittwage.com/files/nibtools/
#
# Based on information gathered from the following resources:
# https://www.lemon64.com/forum/viewtopic.php?p=476726#476726
# http://www.unusedino.de/ec64/technical/formats/d71.html
# http://www.unusedino.de/ec64/technical/formats/d64.html

Clear-Host
# Select the device number of your CBM drive
$SourceDrive=8

Write-host "Checking to see if I can read a directory..."
$status=cbmctrl.exe dir $SourceDrive
# Count the number of lines returned
# - If 1 line returned, it's some kind of error status code from the drive
# - If any other number returns, we got at least the header and blocks free, which means a successful read
$res=($status | Measure-Object -Line).Lines
if ( $res -eq 1 ) {
  Write-host "Something went wrong."
  Write-host $status
  exit
} else {
  Write-host "Directory found"
}

# From here on in, we're ASSUMING that the disk is being read correctly and that no further errors are
#   going to come up.  The OpenCBM tools don't seem to report an error level if a disk becomes unreadable
#   mid-process.
#
# On to the meat and potatos;
#
# Create a temp file to dump the disk image to
$tempfile = Join-Path -Path $env:TEMP -ChildPath readdisk.d64

# Take a snapshot of track 18 (start and end tracks) on drive 8
Write-host "Taking a snapshot of the disks directory"
d64copy -n -q -s 18 -e 18 $SourceDrive $tempfile
# Note that d64copy will make a full size 170kb disk image even if we're just reading a single track

# Read the directory information (Track 18, sector zero, byte 3 and 4)
# We're interested in byte 3 only, but bpeek won't work with 18 0 3 3
$diskdata=c1541 -attach $tempfile -bpeek 18 0 3 4
# Read just the part of the string we want
$disksize=$diskdata[1].substring(5,2)

# Do the basic checks
$Passed=$False;
$nibbleread=$false
if ( $disksize -eq "80" ) { # Bit 128 = 1; Double-Sided Formatted Disk
  Write-host "Disk is Double-Sided"
  $DoubleSided="-2"
  $FileExt=".d71"
  $Passed=$true
}
if ( $disksize -eq "00" ) { # Bit 128 = 0; Single-Sided Formatted Disk
  Write-host "Disk is Single-Sided"
  $DoubleSided=""
  $FileExt=".d64"
  $Passed=$true

  #Check to see if user would like to do a nibble or just do a d64copy
  $wshell = New-Object -ComObject Wscript.Shell
  $nibtools=$wshell.Popup("Do you wish to use NIBREAD to image the disk?`nYes - Use NIBREAD`nNo - Use d64copy",0,"Use the Nibbler?",32+4)
  $nibbleread=$nibtools -eq 6
  if ( $nibbleread -eq $true ) {
      $FileExt=".g64"
  }
}

# .. yeah... whut?
if ( $Passed -eq $False ){
  Write-Output "Unexpected Results.  I don't know what kind of disk this is..."
  exit
}

# Set a default file name then show the user a dialog to save the file as
$OutFile="DiskImage.$(get-date -Format 'yyyy-MM-dd_hh-mm-ss')$FileExt"
Add-Type -AssemblyName System.Windows.Forms
$dlg=New-Object System.Windows.Forms.SaveFileDialog
$dlg.FileName=$OutFile
$dlg.Filter = "*$FileExt|*$FileExt"

# Start the copy process
if($dlg.ShowDialog() -eq 'Ok'){
    Write-Host
    Write-host "Reading Drive $SourceDrive and creating $($dlg.FileName)"
    Write-Host
    $OutFile=$dlg.FileName
    $nibwrite="$($OutFile).nib"
    $nibwritelog="$($OutFile).log"
    if ( $nibbleread -eq $false ) {
      d64copy $DoubleSided $SourceDrive $OutFile
    } else {
      nibread $nibwrite
      nibconv $nibwrite $OutFile
    }
    if (test-path $tempfile) {
      Remove-Item $tempfile -Force
    }
    if (test-path $nibwritelog) {
      Remove-Item $nibwritelog -Force
    }
}
