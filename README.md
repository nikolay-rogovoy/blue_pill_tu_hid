sudo picocom -b 115200 /dev/ttyACM0

git submodule add https://github.com/hathach/tinyusb libs/tinyusb

git submodule update --init --recursive


sudo jstest /dev/input/js0

grep -i -A5 "Blue Pill HID Gamepad" /proc/bus/input/devices

git submodule update --init --recursive
