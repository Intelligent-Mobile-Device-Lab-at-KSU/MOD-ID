# MOD-ID  
MOD-ID (pronounced moded) stands for MOtion Detection on an rfID signal. (The name is a work in progress)
This is the working repository for 'motion detection with a frequency jumping RFID signal'. This repo will focus on detecting motion with a frequency jumping signal.

## Content  
### ./custom_python_blocks  
This directory holds some custom python blocks that are used by the Mobile-Intelligent Device Lab @ KSU (MIDL@KSU). This project specifically uses the items in the frequency jumper portion.  

### trevor_hop.m  
This is the most up to date matlab file that is used for processing the output from the `.grc` file.

### testrfid.grc  
This is the most up to date gnuradio companion file that we have been using to test in the field.

### mod-id.stl  
This is the 3d design model for the most up to date mod-id case being used for field tests.

### ./uhd_drivers  
Recently, we have been developing this project on Windows. Because nothing really plays well with Windows, your version of GNURadio might not recognize the USRP B200mini-i as a SDR (for me it appeared as `westbridge`). To fix this, follow these instructions:  
1.) Open the device manager and plug in the USRP device. You will see an unrecognized USB device in the device manager.  
2.) Right click on the unrecognized USB device and select update/install driver software (may vary for your OS).  
3.) In the driver installation wizard, select "browse for driver", browse to the path/to/this/repo/uhd_drivers. If you are given option to select a specific driver, select the driver for your device. Otherwise, just selecting this directory will do the trick.  
4.) Continue through the installation wizard until the driver is installed.  
([source](https://files.ettus.com/manual/page_transport.html#transport_usb_installwin))