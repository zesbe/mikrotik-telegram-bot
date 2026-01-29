#!/usr/bin/env python3
import subprocess
import os
from telegram import Update, ReplyKeyboardMarkup, KeyboardButton, ReplyKeyboardRemove
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

BOT_TOKEN = "8381226521:AAGUZT97C1idyxO_xZIMWL5pIo5fzoEqqWo"
ALLOWED_CHAT_ID = 1185240496
MIKROTIK_HOST = "10.10.0.2"
MIKROTIK_USER = "tunnel"
MIKROTIK_PASS = "tunnelbekasi"
MIKROTIK_PORT = 2222

# Keyboard layout
MAIN_KEYBOARD = ReplyKeyboardMarkup([
    [KeyboardButton("📊 Status"), KeyboardButton("💻 Resource")],
    [KeyboardButton("🔗 VPN"), KeyboardButton("📈 Traffic")],
    [KeyboardButton("👥 PPPoE"), KeyboardButton("📶 Hotspot")],
    [KeyboardButton("💾 Backup"), KeyboardButton("🔄 Reboot")]
], resize_keyboard=True)

PPPOE_KEYBOARD = ReplyKeyboardMarkup([
    [KeyboardButton("📋 List PPPoE"), KeyboardButton("✅ Active PPPoE")],
    [KeyboardButton("➕ Add PPPoE"), KeyboardButton("❌ Del PPPoE")],
    [KeyboardButton("🔙 Menu Utama")]
], resize_keyboard=True)

HOTSPOT_KEYBOARD = ReplyKeyboardMarkup([
    [KeyboardButton("📋 List Hotspot"), KeyboardButton("✅ Active Hotspot")],
    [KeyboardButton("➕ Add Hotspot"), KeyboardButton("❌ Del Hotspot")],
    [KeyboardButton("🔙 Menu Utama")]
], resize_keyboard=True)

user_states = {}

def run_mikrotik_command(command):
    try:
        cmd = f'sshpass -p "{MIKROTIK_PASS}" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p {MIKROTIK_PORT} {MIKROTIK_USER}@{MIKROTIK_HOST} \'{command}\''
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
        return result.stdout if result.stdout else result.stderr if result.stderr else "OK"
    except subprocess.TimeoutExpired:
        return "Error: Command timeout"
    except Exception as e:
        return f"Error: {str(e)}"

def download_file_from_mikrotik(remote_file, local_file):
    try:
        cmd = f'sshpass -p "{MIKROTIK_PASS}" scp -o StrictHostKeyChecking=no -P {MIKROTIK_PORT} {MIKROTIK_USER}@{MIKROTIK_HOST}:/{remote_file} {local_file}'
        subprocess.run(cmd, shell=True, timeout=60)
        return os.path.exists(local_file)
    except:
        return False

def format_bytes(b):
    try:
        b = int(b)
        if b >= 1073741824: return f"{b/1073741824:.1f} GB"
        elif b >= 1048576: return f"{b/1048576:.1f} MB"
        elif b >= 1024: return f"{b/1024:.1f} KB"
        else: return f"{b} B"
    except:
        return str(b)

def check_auth(chat_id):
    return chat_id == ALLOWED_CHAT_ID

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id):
        await update.message.reply_text("⛔ Unauthorized")
        return
    
    # Force refresh keyboard (clear cached keyboard first)
    await update.message.reply_text("🔄 Loading MikroTik dashboard...", reply_markup=ReplyKeyboardRemove())
    
    help_text = """🤖 *MikroTik Remote Bot*

🎯 **Gunakan keyboard buttons di bawah untuk kontrol MikroTik**

*Optional Commands (manual):*
/status - Info singkat
/resource - CPU, RAM, Uptime  
/vpn - Status VPN
/traffic - Traffic info
/ping <host> - Ping target

*PPPoE Management:*
/addpppoe /delpppoe /listpppoe /activepppoe

*Hotspot Management:*  
/addhotspot /delhotspot /listhotspot /activehotspot

*System Control:*
/backup - Backup config
/reboot - Reboot router

✅ **Keyboard dengan 8 buttons siap digunakan!**
🖥 Router:  (Game Oracle)"""
    
    await update.message.reply_text(help_text, parse_mode='Markdown', reply_markup=MAIN_KEYBOARD)

async def status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    result = run_mikrotik_command('/system resource print')
    await update.message.reply_text(f"📊 *MikroTik Status*\n```\n{result}\n```", parse_mode='Markdown', reply_markup=MAIN_KEYBOARD)

async def resource(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    result = run_mikrotik_command('/system resource print')
    await update.message.reply_text(f"💻 *Resource*\n```\n{result}\n```", parse_mode='Markdown', reply_markup=MAIN_KEYBOARD)

async def vpn(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    result = run_mikrotik_command('/interface l2tp-client print')
    await update.message.reply_text(f"🔗 *VPN Status*\n```\n{result}\n```", parse_mode='Markdown', reply_markup=MAIN_KEYBOARD)

async def traffic(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    result = run_mikrotik_command('/interface print stats')
    await update.message.reply_text(f"📈 *Traffic*\n```\n{result[:3000]}\n```", parse_mode='Markdown', reply_markup=MAIN_KEYBOARD)

async def ping_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    if len(context.args) < 1:
        user_states[update.effective_chat.id] = 'waiting_ping_host'
        await update.message.reply_text("🏓 Ketik host/IP untuk ping:")
        return
    host = context.args[0]
    result = run_mikrotik_command(f'/ping {host} count=4')
    await update.message.reply_text(f"🏓 *Ping {host}*\n```\n{result}\n```", parse_mode='Markdown', reply_markup=MAIN_KEYBOARD)

# PPPoE Commands
async def addpppoe(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    if len(context.args) < 2:
        user_states[update.effective_chat.id] = 'waiting_pppoe_add'
        await update.message.reply_text("➕ Ketik: `username password`", parse_mode='Markdown')
        return
    username, password = context.args[0], context.args[1]
    result = run_mikrotik_command(f'/ppp secret add name={username} password={password} service=pppoe profile=default')
    if "failure" in result.lower() or "error" in result.lower():
        await update.message.reply_text(f"❌ Gagal:\n{result}", reply_markup=PPPOE_KEYBOARD)
    else:
        await update.message.reply_text(f"✅ *PPPoE Created*\n\nUser: `{username}`\nPass: `{password}`", parse_mode='Markdown', reply_markup=PPPOE_KEYBOARD)

async def delpppoe(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    if len(context.args) < 1:
        user_states[update.effective_chat.id] = 'waiting_pppoe_del'
        await update.message.reply_text("❌ Ketik username yang mau dihapus:")
        return
    username = context.args[0]
    run_mikrotik_command(f'/ppp secret remove [find name={username}]')
    await update.message.reply_text(f"🗑 *Deleted*: `{username}`", parse_mode='Markdown', reply_markup=PPPOE_KEYBOARD)

async def listpppoe(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    result = run_mikrotik_command('/ppp secret print')
    await update.message.reply_text(f"📋 *PPPoE Users*\n```\n{result[:3500]}\n```", parse_mode='Markdown', reply_markup=PPPOE_KEYBOARD)

async def activepppoe(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    result = run_mikrotik_command('/ppp active print')
    await update.message.reply_text(f"✅ *Active PPPoE*\n```\n{result[:3500]}\n```", parse_mode='Markdown', reply_markup=PPPOE_KEYBOARD)

# Hotspot Commands
async def addhotspot(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    if len(context.args) < 2:
        user_states[update.effective_chat.id] = 'waiting_hotspot_add'
        await update.message.reply_text("➕ Ketik: `username password`", parse_mode='Markdown')
        return
    username, password = context.args[0], context.args[1]
    result = run_mikrotik_command(f'/ip hotspot user add name={username} password={password}')
    if "failure" in result.lower() or "error" in result.lower():
        await update.message.reply_text(f"❌ Gagal:\n{result}", reply_markup=HOTSPOT_KEYBOARD)
    else:
        await update.message.reply_text(f"✅ *Hotspot User Created*\n\nUser: `{username}`\nPass: `{password}`", parse_mode='Markdown', reply_markup=HOTSPOT_KEYBOARD)

async def delhotspot(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    if len(context.args) < 1:
        user_states[update.effective_chat.id] = 'waiting_hotspot_del'
        await update.message.reply_text("❌ Ketik username yang mau dihapus:")
        return
    username = context.args[0]
    run_mikrotik_command(f'/ip hotspot user remove [find name={username}]')
    await update.message.reply_text(f"🗑 *Deleted*: `{username}`", parse_mode='Markdown', reply_markup=HOTSPOT_KEYBOARD)

async def listhotspot(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    result = run_mikrotik_command('/ip hotspot user print')
    await update.message.reply_text(f"📋 *Hotspot Users*\n```\n{result[:3500]}\n```", parse_mode='Markdown', reply_markup=HOTSPOT_KEYBOARD)

async def activehotspot(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    result = run_mikrotik_command('/ip hotspot active print')
    await update.message.reply_text(f"✅ *Active Hotspot*\n```\n{result[:3500]}\n```", parse_mode='Markdown', reply_markup=HOTSPOT_KEYBOARD)

# System Commands
async def backup(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    await update.message.reply_text("💾 Creating backup...", reply_markup=MAIN_KEYBOARD)
    run_mikrotik_command('/system backup save name=telegram-backup')
    local_file = '/tmp/mikrotik-backup.backup'
    if download_file_from_mikrotik('telegram-backup.backup', local_file):
        await update.message.reply_document(document=open(local_file, 'rb'), filename='mikrotik-backup.backup', caption="✅ Backup complete!")
        os.remove(local_file)
    else:
        await update.message.reply_text("❌ Backup failed", reply_markup=MAIN_KEYBOARD)

async def reboot(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    await update.message.reply_text("🔄 *Rebooting MikroTik...*\nWait 1-2 minutes.", parse_mode='Markdown', reply_markup=MAIN_KEYBOARD)
    run_mikrotik_command('/system reboot')

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not check_auth(update.effective_chat.id): return
    
    text = update.message.text
    chat_id = update.effective_chat.id
    
    # Handle keyboard buttons
    if text == "📊 Status":
        await status(update, context)
    elif text == "💻 Resource":
        await resource(update, context)
    elif text == "🔗 VPN":
        await vpn(update, context)
    elif text == "📈 Traffic":
        await traffic(update, context)
    elif text == "👥 PPPoE":
        await update.message.reply_text("👥 *PPPoE Menu*\nPilih aksi:", parse_mode='Markdown', reply_markup=PPPOE_KEYBOARD)
    elif text == "📶 Hotspot":
        await update.message.reply_text("📶 *Hotspot Menu*\nPilih aksi:", parse_mode='Markdown', reply_markup=HOTSPOT_KEYBOARD)
    elif text == "💾 Backup":
        await backup(update, context)
    elif text == "🔄 Reboot":
        await reboot(update, context)
    elif text == "🔙 Menu Utama":
        await start(update, context)
    # PPPoE submenu
    elif text == "📋 List PPPoE":
        await listpppoe(update, context)
    elif text == "✅ Active PPPoE":
        await activepppoe(update, context)
    elif text == "➕ Add PPPoE":
        user_states[chat_id] = 'waiting_pppoe_add'
        await update.message.reply_text("➕ Ketik: `username password`", parse_mode='Markdown')
    elif text == "❌ Del PPPoE":
        user_states[chat_id] = 'waiting_pppoe_del'
        await update.message.reply_text("❌ Ketik username yang mau dihapus:")
    # Hotspot submenu
    elif text == "📋 List Hotspot":
        await listhotspot(update, context)
    elif text == "✅ Active Hotspot":
        await activehotspot(update, context)
    elif text == "➕ Add Hotspot":
        user_states[chat_id] = 'waiting_hotspot_add'
        await update.message.reply_text("➕ Ketik: `username password`", parse_mode='Markdown')
    elif text == "❌ Del Hotspot":
        user_states[chat_id] = 'waiting_hotspot_del'
        await update.message.reply_text("❌ Ketik username yang mau dihapus:")
    # Handle state input
    elif chat_id in user_states:
        state = user_states[chat_id]
        del user_states[chat_id]
        
        if state == 'waiting_pppoe_add':
            parts = text.split()
            if len(parts) >= 2:
                context.args = parts
                await addpppoe(update, context)
            else:
                await update.message.reply_text("❌ Format: `username password`", parse_mode='Markdown', reply_markup=PPPOE_KEYBOARD)
        elif state == 'waiting_pppoe_del':
            context.args = [text.strip()]
            await delpppoe(update, context)
        elif state == 'waiting_hotspot_add':
            parts = text.split()
            if len(parts) >= 2:
                context.args = parts
                await addhotspot(update, context)
            else:
                await update.message.reply_text("❌ Format: `username password`", parse_mode='Markdown', reply_markup=HOTSPOT_KEYBOARD)
        elif state == 'waiting_hotspot_del':
            context.args = [text.strip()]
            await delhotspot(update, context)
        elif state == 'waiting_ping_host':
            context.args = [text.strip()]
            await ping_cmd(update, context)

def main():
    app = Application.builder().token(BOT_TOKEN).build()
    
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("help", start))
    app.add_handler(CommandHandler("status", status))
    app.add_handler(CommandHandler("resource", resource))
    app.add_handler(CommandHandler("vpn", vpn))
    app.add_handler(CommandHandler("traffic", traffic))
    app.add_handler(CommandHandler("ping", ping_cmd))
    app.add_handler(CommandHandler("addpppoe", addpppoe))
    app.add_handler(CommandHandler("delpppoe", delpppoe))
    app.add_handler(CommandHandler("listpppoe", listpppoe))
    app.add_handler(CommandHandler("activepppoe", activepppoe))
    app.add_handler(CommandHandler("addhotspot", addhotspot))
    app.add_handler(CommandHandler("delhotspot", delhotspot))
    app.add_handler(CommandHandler("listhotspot", listhotspot))
    app.add_handler(CommandHandler("activehotspot", activehotspot))
    app.add_handler(CommandHandler("backup", backup))
    app.add_handler(CommandHandler("reboot", reboot))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    print("MikroTik Bot v2 - Keyboard Enhanced!")
    app.run_polling(drop_pending_updates=True)

if __name__ == "__main__":
    main()
