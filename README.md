# DMSE_status.sh

Bash script to collect system status information from a UniFi Dream Machine and send a formatted status message to a Telegram channel using a bot.<br>
Tested on Dream Machine Special Edition.

## Features

- Collects system, CPU, memory, disk, and hardware information
- Formats the status message for Telegram using MarkdownV2
- Sends notifications to a specified Telegram chat/channel
- Supports silent notifications

## Usage

1. **Configure the script:**
   - Set your Telegram bot token and chat ID in the variables section:
     ```bash
     BOT_TOKEN="your_bot_token"
     CHAT_ID="your_chat_id"
     ```
   - Update the `IPfile` variable to point to your public IP saved in a file, if you have it.

2. **Make the script executable:**
   ```bash
   chmod +x DMSE_status.sh
   ```

3. **Run the script:**
   ```bash
   ./DMSE_status.sh
   ```

## Requirements

- Bash shell
- Utilities: `awk`, `grep`, `df`, `free`, `sensors`, `hddtemp`, `ubnt-device-info`, `ubnt-systool`, `curl`
- A Telegram bot and chat/channel

## Example Output

The script sends a message like this to your Telegram channel:

```
*DMSE - System Status* ℹ️
up 1 weeks, 1 day, 1 hour, 45 minutes

💻 HARDWARE
MB Temp................... 45°C
CPU Temp.................. 60°C
FAN Speed............. 1200 RPM

📄 SOFTWARE
Firmware................ 1.10.0
MAC.......... AA:BB:CC:DD:EE:FF
IP..................... 1.2.3.4
RAM................. 512M/1024M
CPU Load.................... 5%
Load Avg1................. 0.10
Load Avg5................. 0.15
Load Avg15................ 0.20

🌀 STORAGE - /dev/sda
Brand.................. Samsung
Model................... SSD850
Temperature............... 35°C
OS Partition....... 2G/8G - 25%
Data Partition..... 1G/4G - 20%
```

## Notes

- Ensure all required utilities are installed and accessible in your environment.
- The script is designed for UniFi Dream Machine but can be adapted for other systems.
- For MarkdownV2 formatting, only escape the necessary characters as per [Telegram documentation](https://core.telegram.org/bots/api#markdownv2-style).

## License

MIT License

## Authors

CtrlAltJon
