# 💾 Duplicati Telegram Notifications

[![Bash](https://img.shields.io/badge/Language-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)
[![Duplicati](https://img.shields.io/badge/Backup-Duplicati-blue.svg)](https://www.duplicati.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An optimized shell script designed to integrate rich, beautiful, and aesthetic Telegram notifications into your **Duplicati** backup pipelines. It sends structured reports on backup status, files added/modified/deleted, size metrics, and detailed diagnostic logs in case of fatal errors.

---

## 🚀 Key Features

*   **Secure External Configuration**: Keeps sensitive data like your Bot Token and Chat ID safely isolated in an external file (`telegram_config.env`).
*   **Docker Ready**: Native fallback to global environment variables, allowing seamless integration inside Docker containers.
*   **Windows CRLF Safe**: Robust handling of carriage return line endings to prevent syntax errors when running cross-platform.
*   **Rich HTML Formatting**: Clean, styled notifications utilizing Telegram HTML format with status-specific icons (✅, ⚠️, ❌, 💥) for instant overview.
*   **Duration Tracking**: Displays the backup duration (⏱) directly in the notification.
*   **Auto-Update**: Automatically checks GitHub for newer versions on each run and updates itself.

---

## 🛠️ Setup & Configuration

### 1. Download the script
Ensure `notify_to_telegram.sh` is present in your project directory and set as executable:
```bash
chmod +x notify_to_telegram.sh
```

### 2. Configure credentials
1. Copy the example configuration template:
   ```bash
   cp telegram_config.env.example telegram_config.env
   ```
2. Open `telegram_config.env` and enter your specific Telegram Token and Chat ID:
   ```env
   TELEGRAM_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
   TELEGRAM_CHATID="YOUR_TELEGRAM_CHAT_ID"
   ```

*Note: `telegram_config.env` is pre-configured in `.gitignore` to prevent any accidental leaks to your remote git repositories.*

---

## ⚙️ Integrating with Duplicati

Configure the script to run before or after your backup operations directly via the Duplicati UI (Advanced Options) or using CLI arguments:

*   **After backups**:
    `--run-script-after = /path/to/notify_to_telegram.sh`
*   **Before backups**:
    `--run-script-before = /path/to/notify_to_telegram.sh`

---

## 🔄 Auto-Update

The script automatically checks for new versions on GitHub at each run. If a newer version is found, it downloads and replaces itself transparently before executing.

### Disable auto-update

Set the `SKIP_UPDATE` environment variable to skip the update check:

```bash
SKIP_UPDATE=1 ./notify_to_telegram.sh
```

Or export it in your environment / `telegram_config.env`:

```env
SKIP_UPDATE=1
```

---

## ⚖️ Disclaimer (AS IS)

> [!WARNING]
> **RELEASED "AS IS"**
> 
> This software is provided **"as is"**, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement.
> 
> In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
