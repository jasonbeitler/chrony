#!/bin/zsh

#Setup Chrony for encrypted time sync

#Install Chrony
brew install chrony

mkdir /opt/homebrew/etc/chrony

#Setup Chrony config
cat > /opt/homebrew/etc/chrony/chrony.conf <<EOF
server time.cloudflare.com iburst nts
server ntppool1.time.nl iburst nts
server nts.netnod.se iburst nts
server ptbtime1.ptb.de iburst nts

#move pid for macos
pidfile /opt/homebrew/etc/chrony/chronyd.pid

# This directive specify the location of the file containing ID/key pairs for
# NTP authentication.
keyfile /opt/homebrew/etc/chrony/chrony.keys

# This directive specify the file into which chronyd will store the rate
# information.
driftfile /opt/homebrew/chrony/chrony.drift

# Save NTS keys and cookies.
ntsdumpdir /opt/homebrew//chrony

# Stop bad estimates upsetting machine clock.
maxupdateskew 100.0

# This directive enables kernel synchronisation (every 11 minutes) of the
# real-time clock. Note that it can't be used along with the 'rtcfile' directive.
rtcsync

# Step the system clock instead of slewing it if the adjustment is larger than
# one second, but only in the first three clock updates.
makestep 1 3

# Get TAI-UTC offset and leap seconds from the system tz database.
# This directive must be commented out when using time sources serving
# leap-smeared time.
leapsectz right/UTC
EOF


#Setup Chrony Launch Daemon
sudo bash -c 'cat > /Library/LaunchDaemons/com.chrony.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.chrony</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/sbin/chronyd</string>
        <string>-f</string>
        <string>/opt/homebrew/etc/chrony/chrony.conf</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/var/log/chrony.err</string>
    <key>StandardOutPath</key>
    <string>/var/log/chrony.out</string>
</dict>
</plist>
EOF'

#Disable NTP
sudo systemsetup -setusingnetworktime off

#Launch Chrony now and on boot
sudo launchctl load /Library/LaunchDaemons/com.chrony.plist

sleep 20

chronyc tracking

