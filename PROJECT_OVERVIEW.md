# Optimise-CS2 — Project Overview

## What is Optimise-CS2?

A lightweight PowerShell automation tool that optimizes your Windows 11 PC for competitive gaming on poor internet conditions. It temporarily disables bandwidth-consuming background services (Windows Update, Delivery Optimization, OneDrive sync, etc.) to dedicate maximum network resources to your game, then automatically restores everything when you close the game.

**In short:** Run → Game gets priority → Close game → System restored automatically.

---

## The Problem It Solves

Playing competitive games (CS2, Valorant, etc.) on limited internet is frustrating. While you're trying to clutch a round, Windows is:
- Downloading updates in the background (Delivery Optimization)
- Syncing your files to OneDrive
- Running Windows Update checks
- Starting BITS transfers

This consumes precious bandwidth that could go to your game, causing lag spikes, packet loss, and ruined matches.

**Optimise-CS2 pauses all that automatically—just for gaming.**

---

## Key Features

✅ **One-click optimization** — Run the script, gaming starts  
✅ **Automatic cleanup** — Everything restores when game closes  
✅ **Safe by default** — Only stops non-critical services  
✅ **Aggressive mode** — Maximum bandwidth for hardcore gamers  
✅ **Zero configuration** — Works out of the box  
✅ **Reversible** — No permanent system changes  

---

## Current Status

**Version:** 1.0.0  
**Status:** Stable & Production-Ready  
**Tested on:** Windows 11 (PowerShell 5.1)  
**License:** MIT (open-source)

---

## 🔧 Areas Open for Improvement

We're actively looking for community contributions! Here are some areas where you can help:

### High Priority
- **Cross-platform support** — Adapt for Windows 10 compatibility testing
- **Additional game detection** — Expand process name list (Apex, Valorant, Fortnite, etc.)
- **GUI wrapper** — Create a simple interface so users don't need PowerShell
- **Scheduled optimization** — Add cron-like scheduling for auto-start

### Medium Priority
- **Network stats monitoring** — Show bandwidth/latency during gameplay
- **Config file support** — Let users save preferred settings
- **Logging & analytics** — Track optimization impact over time
- **Service whitelist** — Allow users to specify which services to pause

### Nice-to-Have
- **Router integration** — Read/apply QoS rules directly
- **Performance benchmarking** — Before/after ping tests
- **Telemetry dashboard** — Show what was optimized and when
- **Multi-game profiles** — Different settings per game

---

## 💡 Community Suggestions Welcome

Have an idea? Found a bug? Here's how to contribute:

### Suggest Improvements
- Open a GitHub issue with your idea
- Label it `enhancement` or `suggestion`
- Describe the use case

### Report Issues
- Post error messages with steps to reproduce
- Include your Windows/PowerShell version
- Expected vs. actual behavior

### Submit Code
- Fork the repo
- Create a feature branch (`feature/my-feature`)
- Submit a pull request with clear description
- Make sure it works on Windows 11 + PowerShell 5.1

### Test & Feedback
- Try it with different games and internet speeds
- Report which games work/don't work
- Share performance improvements you notice

---

## 🚀 Roadmap (Potential)

**v1.1** (Next)
- Windows 10 compatibility
- Extended game detection
- Config file support

**v1.2** (Future)
- GUI application
- Performance logging
- Advanced scheduling

**v2.0** (Long-term)
- Multi-platform support (Linux/Mac via alternative tools)
- AI-based bandwidth optimization
- Real-time network monitoring

---

## How to Get Involved

1. **Try it out** — Use it, give feedback
2. **Star on GitHub** — Show your support
3. **Report issues** — Help us fix bugs
4. **Submit PRs** — Contribute features
5. **Spread the word** — Tell your gamer friends!

---

## Quick Links

- 📖 **Documentation** — See README.md
- 🐛 **Report Bugs** — GitHub Issues
- 💬 **Discussions** — GitHub Discussions
- 📝 **License** — MIT License

---

## Support

- **Questions?** Open a GitHub Discussion
- **Bug?** Open a GitHub Issue with reproduction steps
- **Feature request?** Use GitHub Issues with `enhancement` label

---

**Made for gamers, by gamers. Optimize your game. Win more rounds.**

---

*Last updated: May 2026*
