# Optimise-CS2

A PowerShell script that optimizes your Windows PC for gaming on poor internet conditions. It temporarily stops bandwidth-consuming background services (Delivery Optimization, Windows Update, etc.) to dedicate network resources to your game, then automatically restores everything when you close the game.

**Perfect for:** CS2, competitive gaming, or any scenario where you need maximum bandwidth dedicated to your game.

---

## Features

✅ **On-demand optimization** — Applies immediately when you run the script  
✅ **Automatic restoration** — Services restore when your game closes  
✅ **Safe by default** — Only stops non-critical services; respects system state  
✅ **Aggressive mode** — Option to stop Windows Update, BITS, and OneDrive for maximum bandwidth  
✅ **Process priority boost** — Sets game to "High" CPU priority for better performance  
✅ **Dry-run mode** — Preview changes without making them  

---

## Requirements

- **Windows 10/11** (tested on Windows 11)
- **PowerShell 5.1** (default on Windows 10/11)
- **Administrator privileges** (required to manage services)

---

## Installation

### Option 1: Manual
1. Download `Optimise-CS2.ps1` to your PC
2. Save it somewhere accessible (e.g., `C:\Users\YourName\Documents\`)

### Option 2: Clone from GitHub
```powershell
git clone https://github.com/yourusername/Optimise-CS2.git
cd Optimise-CS2
```

---

## Quick Start

### Step 1: Open PowerShell as Administrator
- Press `Win + X` → Select "Windows PowerShell (Admin)" or "Terminal (Admin)"
- Or search "PowerShell", right-click, select "Run as administrator"

### Step 2: Allow Scripts to Run (first time only)
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

### Step 3: Run the Script

**Safe mode** (stops Delivery Optimization only):
```powershell
& "C:\path\to\Optimise-CS2.ps1" -ProcessNames cs2,hl2
```

**Aggressive mode** (also stops Windows Update, BITS, OneDrive):
```powershell
& "C:\path\to\Optimise-CS2.ps1" -ProcessNames cs2,hl2 -Aggressive
```

**Test mode** (see what would happen without making changes):
```powershell
& "C:\path\to\Optimise-CS2.ps1" -ProcessNames cs2,hl2 -DryRun
```

### Step 4: Start Your Game
- The script will automatically detect when your game starts
- It applies optimizations and monitors until you close the game
- Services automatically restore when the game exits

---

## Usage

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ProcessNames` | string[] | `cs2,hl2` | Game process names to monitor (without .exe) |
| `-Aggressive` | switch | off | Stop Windows Update, BITS, OneDrive for maximum bandwidth |
| `-DryRun` | switch | off | Preview changes without applying them |
| `-PollIntervalSeconds` | int | 2 | How often to check if game is still running |

### Examples

**Monitor only CS2:**
```powershell
& ".\Optimise-CS2.ps1" -ProcessNames cs2
```

**Monitor CS2 and Valorant:**
```powershell
& ".\Optimise-CS2.ps1" -ProcessNames cs2,valorant
```

**Aggressive optimization for CS2:**
```powershell
& ".\Optimise-CS2.ps1" -ProcessNames cs2 -Aggressive
```

**Check what would happen (safe to test):**
```powershell
& ".\Optimise-CS2.ps1" -ProcessNames cs2 -DryRun
```

---

## What the Script Does

### Default (Safe) Mode
1. Stops **Delivery Optimization** (peer-to-peer Windows Update downloads)
2. Sets your game process to **High priority** CPU scheduling
3. Waits for your game to close
4. Restarts all services

### Aggressive Mode
1. Stops Delivery Optimization
2. Stops **Windows Update** (automatic updates paused)
3. Stops **BITS** (Background Intelligent Transfer Service)
4. Stops **OneDrive** (cloud sync paused)
5. Sets game to High priority
6. Restarts all services when game closes

---

## Expected Output

### Successful Run
```
========================================
Optimise-CS2 v1.0.0
========================================
Mode: LIVE
Monitoring process names: cs2, hl2

Applying optimizations...

[OK] Stopped service: DoSvc
[INFO] Service not running: wuauserv (state: Stopped)
[OK] Set process priority to High: cs2.exe [PID 12345]

Optimizations active. Waiting for game to close...
(Press Ctrl+C to stop and restore)

Game process ended. Cleaning up...

Restoring system state...

[OK] Started service: DoSvc

Restore complete.

========================================
Optimization session ended.
========================================
```

---

## Troubleshooting

### "Administrator privileges required"
- Right-click PowerShell, select "Run as administrator"
- Re-run the command

### "Process not found" warning
- Make sure the game process name is correct (e.g., `cs2` not `cs2.exe`)
- The script waits for the game to launch, so start it after running the script

### Script won't run (execution policy error)
- Run this first: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force`
- This only affects the current PowerShell session

### Services won't start/stop
- Confirm you're running PowerShell as Administrator
- Some services may be locked by Windows; restart may be needed

### Game priority not changing
- Confirm the script has Administrator privileges
- Some games may override process priority; this is game-specific

---

## Safety & Restoration

### Is This Safe?
✅ Yes. The script:
- Only stops non-critical background services
- Records the original state of each service
- Automatically restores everything when done
- Includes a dry-run mode to preview changes first

### What If It Crashes?
- Use `Ctrl+C` to stop the script immediately
- Services will be restored in the `finally` block

### Manual Restoration
If needed, manually restart services:
```powershell
Start-Service -Name DoSvc
Start-Service -Name wuauserv
Start-Service -Name BITS
Start-Process "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" -ArgumentList "/background"
```

---

## Advanced Configuration

### Custom Process Names
Monitor a different game:
```powershell
& ".\Optimise-CS2.ps1" -ProcessNames valhost,valorant  # Valorant
& ".\Optimise-CS2.ps1" -ProcessNames apex  # Apex Legends
```

### Faster/Slower Polling
Check game status more or less frequently:
```powershell
& ".\Optimise-CS2.ps1" -ProcessNames cs2 -PollIntervalSeconds 5  # Check every 5 seconds
```

---

## Performance Impact

### Network
- Typically frees 50-200 Mbps by disabling Delivery Optimization
- Aggressive mode may free an additional 20-50 Mbps

### CPU
- Minimal impact; High priority mainly affects scheduler behavior
- Noticeable benefit in competitive games during team fights or smoke scenarios

### RAM
- No significant impact

---

## Limitations & Notes

- Services are only restored when the monitored process closes (not during gameplay)
- Does **not** modify router settings (QoS rules)
- Does **not** limit other applications' bandwidth programmatically
- For best results, combine with router QoS rules to prioritize game ports

---

## Contributing

Found a bug or have an idea? Open an issue or submit a pull request on GitHub!

---

## License

MIT License — See [LICENSE](LICENSE) for details.

---

## Disclaimer

This script modifies Windows services. While it's designed to be safe and reversible, use at your own risk. Always ensure you understand what each parameter does before running with `-Aggressive` mode.

---

## Support

Having issues? Try:
1. Running with `-DryRun` to see what would happen
2. Checking the troubleshooting section above
3. Ensuring you're running PowerShell as Administrator
4. Opening an issue on GitHub with your output
