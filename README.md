# MikroTik Telegram Bot

🤖 Advanced Telegram Bot for MikroTik RouterOS Management

## Features

- 📊 **System Monitoring**: CPU, Memory, Uptime
- 🌐 **Interface Management**: Status, Stats, Control
- 🔗 **VPN Monitoring**: L2TP, OpenVPN connections
- 📈 **Traffic Analysis**: Real-time interface monitoring
- 👥 **PPPoE Management**: User creation, deletion, monitoring
- 📶 **Hotspot Control**: User management, active sessions
- 💾 **Backup & Restore**: System backup download
- 🔄 **Remote Reboot**: Safe system restart
- 🏓 **Network Tools**: Ping, connectivity tests
- ⌨️ **Keyboard Interface**: Easy-to-use button layout

## Requirements

- Python 3.8+
- MikroTik RouterOS with API enabled
- Telegram Bot Token
- SSH access to MikroTik device

## Installation

### 1. Clone Repository
```bash
git clone https://github.com/zesbe/mikrotik-telegram-bot.git
cd mikrotik-telegram-bot
```

### 2. Install Dependencies
```bash
pip3 install -r requirements.txt
```

### 3. Configure Bot
Edit `bot.py` and update:
```python
BOT_TOKEN = "YOUR_BOT_TOKEN"
ALLOWED_CHAT_ID = YOUR_TELEGRAM_USER_ID
MIKROTIK_HOST = "MIKROTIK_IP_ADDRESS"
MIKROTIK_USER = "mikrotik_username"
MIKROTIK_PASS = "mikrotik_password"
MIKROTIK_PORT = 22  # or custom SSH port
```

### 4. Setup SystemD Service
```bash
sudo cp mikrotik-bot.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mikrotik-bot
sudo systemctl start mikrotik-bot
```

## MikroTik Configuration

### Enable API Service
```
/ip service enable api
```

### Create Bot User (Recommended)
```
/user add name=botuser password=securepass group=full
```

### Configure SSH Access
```
/ip service set ssh port=2222
```

## Usage

1. Start conversation with your bot
2. Send `/start` to see main menu
3. Use keyboard buttons or commands:
   - 📊 **Status** - System information
   - 💻 **Resource** - CPU/Memory usage
   - 🔗 **VPN** - VPN connections status
   - 📈 **Traffic** - Interface statistics
   - 👥 **PPPoE** - PPPoE user management
   - 📶 **Hotspot** - Hotspot user management
   - 💾 **Backup** - Download system backup
   - 🔄 **Reboot** - Restart router

## Commands

- `/start` - Show main menu
- `/status` - System status
- `/resource` - Resource usage
- `/vpn` - VPN status
- `/traffic` - Traffic stats
- `/ping <host>` - Ping test
- `/backup` - System backup
- `/reboot` - Restart router

## Security

- Bot only responds to authorized chat ID
- SSH connection with timeout protection
- No sensitive data logged
- Secure credential handling

## Deployment

### Docker Deployment
```bash
docker build -t mikrotik-bot .
docker run -d --name mikrotik-bot --restart unless-stopped mikrotik-bot
```

### SystemD Service
Service file included for Linux deployment with auto-restart and logging.

## Troubleshooting

### Connection Issues
- Verify MikroTik SSH access
- Check firewall rules
- Confirm API service enabled

### Bot Not Responding
- Check bot token validity
- Verify user chat ID
- Review systemd logs: `journalctl -u mikrotik-bot -f`

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

MIT License - Free to use and modify

## Support

For issues and feature requests, please use GitHub Issues.

---

**🚀 Built with ❤️ for MikroTik automation**