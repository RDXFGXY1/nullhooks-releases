# NullHooks v1.3 - Cybernetic Webhook Management System

**[Secure JSON Core | ANSI Interface | Encrypted Persistence]**  
Copyright © **Made @K Y R O S ! & @K Y R A S !**  
Visit: [DarkOPS HQ](https://darkops-hq.web.app/)  

---

## Overview

NullHooks is a secure and feature-rich webhook management tool written in Lua, designed for managing Discord webhooks with an interactive ANSI-styled interface and JSON-based data storage. It features encrypted persistence for saved webhooks and provides customizable webhook profiles.

---

## Features

- **Secure Webhook Management**: Add, send, and manage Discord webhooks easily.
- **Network Diagnostics**: Ensures network connectivity before performing operations.
- **Encrypted Data Storage**: Stores webhook configurations securely.
- **Custom ANSI Interface**: Styled with ANSI color codes for a cyber-style terminal experience.

---

## Prerequisites

To use NullHooks, you'll need the following:

1. **LuaJIT** (Just-In-Time Compiler for Lua)  
2. **Lua Libraries**: 
    - `socket` (Networking)  
    - `ltn12` (Data transfer)  
    - `dkjson` (JSON parsing and encoding)  

### Installation

1. **Install LuaJIT**:
   - On Linux:  
     ```bash
     sudo apt update && sudo apt install luajit
     ```
   - On macOS (using Homebrew):  
     ```bash
     brew install luajit
     ```

2. **Install Required Lua Libraries**:
   - Use `luarocks` to install the dependencies:  
     ```bash
     luarocks install luasocket
     luarocks install dkjson
     ```

---

## How to Run NullHooks

1. **Clone or download** the script.  
2. Open your terminal and navigate to the script's directory.
3. Run the script using `luajit`:  
   ```bash
   luajit nullhooks.lua
   ```

---

## Usage Instructions

Once the script is running, you'll see the **NullHooks** banner and prompt. Here’s what you can do:

### Commands:

1. **Add a Webhook**  
   Register a new webhook with a unique identifier and its corresponding URL.
   ```text
   [+] Webhook Registration Protocol
   Enter unique identifier: webhook1
   Enter webhook endpoint URL: https://discord.com/api/webhooks/ID/TOKEN
   ```

2. **Send a Webhook**  
   Send a message to the registered webhook. Customize the username and content for the message.
   
3. **List Active Webhooks**  
   Displays all stored webhooks.

4. **Custom Webhook Profiles**  
   Supports custom profiles for managing multiple webhook configurations.

---

## Example Output

```text
[✓] System initialized in exactly 2.00 seconds
[✓] Secure tunnel established (50ms)
Running integrity checks:
├─ Loading crypto modules...
└─ Accessing data vaults...
[✓] All systems operational
```

---

## License

This project is licensed under the MIT License. Use it responsibly.

---

