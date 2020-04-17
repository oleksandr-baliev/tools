#!/bin/bash
# Helps to configure facetime camera for Ubuntu on Macbook
# Credit to https://linuxnewbieguide.org/how-to-install-linux-on-a-macintosh-computer/

printf "Update cloned repo\n";
sudo rm -r bcwc_pcie
git clone https://github.com/patjak/bcwc_pcie.git
printf "done\n\n";

cd bcwc_pcie/firmware

printf "Compiling firmware\n";
make
printf "done\n\n";

printf "Installing firmware\n";
sudo make install
printf "done\n\n";

cd ..

printf "Compiling driver\n";
make
printf "done\n\n";

printf "Installing driver\n";
sudo make install
printf "done\n\n";

printf "Running depmod\n";
sudo depmod
printf "done\n\n";

printf "Running modprobe -r bdc_pci\n";
sudo modprobe -r bdc_pci
printf "done\n\n";

printf "Loading driver\n";
sudo modprobe facetimehd
printf "done\n\n";
