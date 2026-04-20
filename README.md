# 📦 dzns_drugs

A complete drug system for FiveM featuring gathering, processing, and selling.

## ✨ Features

* 🌿 Drug collection system
* 🧪 Processing raw materials into drugs
* 💰 Selling drugs to NPCs
* 📍 Configurable locations (farm, process, sell)
* 🎭 Animations for actions
* 🎯 ox_target support
* 📡 Optional Discord logging
* ⚙️ Fully configurable

---

## 🎮 Gameplay Flow

1. **Collect**

   * Go to drug farming locations
   * Gather raw materials

2. **Process**

   * Convert raw materials into usable drugs

3. **Sell**

   * Sell drugs to NPC or designated location
   * Earn money

---

## 📥 Installation

1. Put the resource into your `resources` folder
2. Rename if needed:

   ```
   dzns_drugs
   ```
3. Add to `server.cfg`:

   ```
   ensure dzns_drugs
   ```

---

## ⚙️ Requirements

* ESX (`es_extended`)
* ox_target (recommended)

---

## 🛠️ Configuration

Edit everything inside:

```
config.lua
```

### 🔧 Configurable Options

* Drug types
* Harvest locations
* Processing locations
* Selling locations
* Rewards / prices
* Required item amounts
* Cooldowns

---

## 📁 Files

* `client.lua` – interactions, zones, animations
* `server.lua` – item handling, rewards, selling
* `config.lua` – main configuration

---

## 📡 Discord Logs

Supports logging for:

* collecting
* processing
* selling

Set your webhook in config.

---

## 👤 Author

**al1qzx**

## 💵 Price

**FREE**


Add this to ox_invetory :


['sacok'] = {
    label = 'Sáčok',
    weight = 10,
    stack = true,
    close = true,
},

['coca_leaf'] = {
    label = 'Lístok koky',
    weight = 20,
    stack = true,
    close = true,
},

['dried_coca'] = {
    label = 'Sušený koks',
    weight = 30,
    stack = true,
    close = true,
},

['cocaine_bag'] = {
    label = 'Sáčok kokaínu',
    weight = 50,
    stack = true,
    close = true,
},

Add icons from /data folder to ox_invetory/web/images

al1qzx | 2026
