#!/bin/bash

# ############################################################################################################
# Sends a status message about the console Unifi Dream Machine to a Telegram channel.
#
# Usage: DMSE_status.sh
#
# ############################################################################################################

# --- FUNCTION ---------------------------------------------------------- Escape Markdown --------------------
# ------------------------------------------------------------------------------------------------------------
# Function to escape MarkdownV2 special characters for Telegram.
escape_markdown() {
  local text="$1"
  text="${text//\\/\\\\}"                # <<<<<< Escape backslash first

  text="${text//\./\\\.}"
  text="${text//\!/\\\!}"
  #text="${text//\(/\\\(}"
  #text="${text//\)/\\\)}"
  #text="${text//\[/\\\[}"
  #text="${text//\]/\\\]}"
  text="${text//\-/\\\-}"
  #text="${text//\%/\\\%}"
  #text="${text//\_/\\\_}"
  #text="${text//\*/\\\*}"
  #text="${text//\~/\\\~}"
  #text="${text//\`/\\\`}"
  text="${text//\>/\\\>}"
  text="${text//\#/\\\#}"
  text="${text//\+/\\\+}"
  text="${text//\=/\\\=}"
  #text="${text//\|/\\\|}"
  text="${text//\{/\\\{}"
  text="${text//\}/\\\}}"
  printf '%s' "$text"
}


# ----------------------------------------------------------------------- Variables initialization -----------
# ------------------------------------------------------------------------------------------------------------
SILENT_NOTIFICATION=false                                            # Set to true to send telegram silent notifications
BOT_TOKEN="0000000000:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"           # Telegram bot token
CHAT_ID="-000000000000"                                              # Telegram chat ID

VAR_DOTS=".................................................."        # Dots for line padding
VAR_WIDTH=30                                                         # Width of the output text lines

IPfile="/path/to/file/IP.txt"                                        # File on the console containing the Public IP address.
                                                                     # You may have an external script that updates this file.
if [[ -f "$IPfile" ]]; then                                          # If the file exists
  read -r VAR_IP < "$IPfile"                                         # Read the Public IP address from the file
else
  VAR_IP="Unknown"
fi

# System
VAR_FIRM=$(ubnt-device-info firmware)                                # Get the firmware version of the device
VAR_UPTIME=$(uptime -p)                                              # Get the system uptime in a human-readable format
VAR_MAC=$(ubnt-device-info mac)                                      # Get the MAC address of the device

# CPU
VAR_LOADAVG1=$(uptime | awk '{ print $10 }')                         # Get the 1-minute load average
VAR_LOADAVG5=$(uptime | awk '{ print $11 }')                         # Get the 5-minute load average
VAR_LOADAVG15=$(uptime | awk '{ print $12 }')                        # Get the 15-minute load average
VAR_CPULOAD=$(ubnt-systool cpuload)                                  # Get the CPU load percentage
VAR_CPUTEMP=$(ubnt-systool cputemp)                                  # Get the CPU temperature

# Disks (For other installed drives, complete with your own code)
VAR_SDA_BRAND=$(hddtemp /dev/sda | awk '{ print $2 }')               # Get the brand of the hard drive
VAR_SDA_MODEL=$(hddtemp /dev/sda | awk '{ print $3 }')               # Get the model of the hard drive
VAR_SDA_TEMP=$(hddtemp /dev/sda | awk '{ print $4 }')                # Get the temperature of the hard drive

# Hardware
VAR_MBTEMP=$(sensors | grep "Board Temp" | awk '{ print $3 }')       # Get the motherboard temperature
VAR_FANSPEED=$(sensors | grep "fan2" | awk '{ print $2 }')           # Get the fan speed

# Memory
VAR_MEMTOT=$(free -h | grep "Mem" | awk '{ print $2 }')              # Get the total memory
VAR_MEMUSED=$(free -h | grep "Mem" | awk '{ print $3 }')             # Get the used memory

# Disks Usage
VAR_DISK1_TOT=$(df -h | grep "overlayfs-root" | awk '{ print $2 }')  # Get the total space on the OS partition
VAR_DISK1_USED=$(df -h | grep "overlayfs-root" | awk '{ print $3 }') # Get the used space on the OS partition
VAR_DISK1_PERC=$(df -h | grep "overlayfs-root" | awk '{ print $5 }') # Get the percentage used on the OS partition
VAR_DISK2_TOT=$(df -h | grep "ssd1" | awk '{ print $2 }')            # Get the total space on the data partition
VAR_DISK2_USED=$(df -h | grep "ssd1" | awk '{ print $3 }')           # Get the used space on the data partition
VAR_DISK2_PERC=$(df -h | grep "ssd1" | awk '{ print $5 }')           # Get the percentage used on the data partition

# ----------------------------------------------------------------------- Main -------------------------------
# ------------------------------------------------------------------------------------------------------------
TEXT="*DMSE - System Status* %E2%84%B9%0A"                           # Start the message with the title
TEXT+="\`\`\`"                                                       # Start a code block for formatting
TEXT+="%0A${VAR_UPTIME}"                                             # Add the system uptime

TEXT+="%0A%0A %F0%9F%92%BB HARDWARE"                                 # Add a section header for hardware
TEXT+="%0A"                                                          # New line
TEXT+="MB Temp"                                                      # Add the motherboard temperature
Tmp=$(( VAR_WIDTH - 5 - ${#VAR_MBTEMP} ))                            # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_MBTEMP:1}°C"                                           # Add the temperature value (removing the first character)
TEXT+="%0A"                                                          # New line
TEXT+="CPU Temp"                                                     # Add the CPU temperature
Tmp=$(( VAR_WIDTH - 7 - ${#VAR_CPUTEMP} ))                           # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_CPUTEMP}°C"                                            # Add the temperature value
TEXT+="%0A"                                                          # New line
TEXT+="FAN Speed"                                                    # Add the fan speed
Tmp=$(( VAR_WIDTH - 10 - ${#VAR_FANSPEED} ))                         # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_FANSPEED} RPM"                                         # Add the fan speed value

TEXT+="%0A%0A %F0%9F%93%84 SOFTWARE"                                 # Add a section header for software
TEXT+="%0A"                                                          # New line
TEXT+="Firmware"                                                     # Add the firmware version
Tmp=$(( VAR_WIDTH - 5 - ${#VAR_FIRM} ))                              # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_FIRM}"                                                 # Add the firmware version value
TEXT+="%0A"                                                          # New line
TEXT+="MAC"                                                          # Add the MAC address
Tmp=$(( VAR_WIDTH - ${#VAR_MAC} ))                                   # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_MAC}"                                                  # Add the MAC address value
TEXT+="%0A"                                                          # New line
TEXT+="IP"                                                           # Add the Public IP address
Tmp=$(( VAR_WIDTH + 1 - ${#VAR_IP} ))                                # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_IP}"                                                   # Add the Public IP address value
TEXT+="%0A"                                                          # New line
TEXT+="RAM"                                                          # Add the RAM usage
Tmp=$(( VAR_WIDTH - 1 - ${#VAR_MEMUSED} - ${#VAR_MEMTOT} ))          # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_MEMUSED}/${VAR_MEMTOT}"                                # Add the RAM usage value
TEXT+="%0A"                                                          # New line
TEXT+="CPU Load"                                                     # Add the CPU load percentage
Tmp=$(( VAR_WIDTH - 6 - ${#VAR_CPULOAD} ))                           # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_CPULOAD}%"                                             # Add the CPU load percentage value
TEXT+="%0A"                                                          # New line
TEXT+="Load Avg1"                                                    # Add the 1-minute load average
Tmp=$(( VAR_WIDTH - 5 - ${#VAR_LOADAVG1} ))                          # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_LOADAVG1%?}"                                           # Add the 1-minute load average value (removing the last character)
TEXT+="%0A"                                                          # New line
TEXT+="Load Avg5"                                                    # Add the 5-minute load average
Tmp=$(( VAR_WIDTH - 5 - ${#VAR_LOADAVG5} ))                          # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_LOADAVG5%?}"                                           # Add the 5-minute load average value (removing the last character)
TEXT+="%0A"                                                          # New line
TEXT+="Load Avg15"                                                   # Add the 15-minute load average
Tmp=$(( VAR_WIDTH - 7 - ${#VAR_LOADAVG15} ))                         # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_LOADAVG15}"                                            # Add the 15-minute load average value

TEXT+="%0A%0A %F0%9F%93%80 STORAGE - /dev/sda"                       # Add a section header for storage
TEXT+="%0A"                                                          # New line
TEXT+="Brand"                                                        # Add the brand of the hard drive
Tmp=$(( VAR_WIDTH - 2 - ${#VAR_SDA_BRAND} ))                         # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_SDA_BRAND}"                                            # Add the brand value
TEXT+="%0A"                                                          # New line
TEXT+="Model"                                                        # Add the model of the hard drive
Tmp=$(( VAR_WIDTH - 3 - ${#VAR_SDA_MODEL} ))                         # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_SDA_MODEL%?}"                                          # Add the model value (removing the last character)
TEXT+="%0A"                                                          # New line
TEXT+="Temperature"                                                  # Add the temperature of the hard drive
Tmp=$(( VAR_WIDTH - 10 - ${#VAR_SDA_TEMP} ))                         # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_SDA_TEMP}°C"                                           # Add the temperature value
TEXT+="%0A"                                                          # New line
TEXT+="OS Partition"                                                 # Add the OS partition usage
Tmp=$(( VAR_WIDTH - 11 - ${#VAR_DISK1_USED} - ${#VAR_DISK1_TOT} - ${#VAR_DISK1_PERC} - 3 )) # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_DISK1_USED}/${VAR_DISK1_TOT} - ${VAR_DISK1_PERC}"      # Add the OS partition usage value
TEXT+="%0A"                                                          # New line
TEXT+="Data Partition"                                               # Add the data partition usage
Tmp=$(( VAR_WIDTH - 13 - ${#VAR_DISK2_USED} - ${#VAR_DISK2_TOT} - ${#VAR_DISK2_PERC} - 3 )) # Calculate the padding needed
TEXT+="${VAR_DOTS:0:$Tmp}"                                           # Add dots for padding
TEXT+=" ${VAR_DISK2_USED}/${VAR_DISK2_TOT} - ${VAR_DISK2_PERC}"      # Add the data partition usage value

TEXT+="\`\`\`"                                                       # End the code block for formatting

ESCAPED_TEXT=$(escape_markdown "$TEXT")                              # Escape the text for MarkdownV2

# ----------------------------------------------------------------------- Send to Telegram -------------------
# ------------------------------------------------------------------------------------------------------------
# Replace YOUR_BOT_TOKEN and YOUR_CHAT_ID at the top of this script in the Variables initialization section
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d chat_id="${CHAT_ID}" \
    -d text="${ESCAPED_TEXT}" \
    -d disable_notification="${SILENT_NOTIFICATION}" \
    -d parse_mode=MarkdownV2 > /dev/null

exit 0
