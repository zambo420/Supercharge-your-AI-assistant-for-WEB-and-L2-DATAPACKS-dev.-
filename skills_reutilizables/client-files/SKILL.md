---
name: client-files
description: >
  Working with Lineage 2 client files: textures, maps, L2Text, system configs.
  Trigger: When modifying client files in Cliente/
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [client, textures, maps, l2text]
  auto_invoke: "client texture, client map, l2text, systemmsg, client interface"
allowed-tools: Read, Edit, Write, Glob, Grep
---

## When to Use

- Modifying client textures (.utx files)
- Editing L2Text files (systemmsg, NPC names)
- Working with client system configuration
- Modifying maps or static meshes (advanced)

---

## Directory Structure

```
Cliente/ClassicInterludeServer/
├── system/                      # System configs (encrypted)
│   ├── L2.ini                   # Main client config
│   ├── Option.ini               # Client options
│   ├── user.ini                 # User settings
│   └── *.dll                    # Client libraries
│
├── system_en/                   # English localization
│   └── *.dat                    # Encrypted data files
│
├── L2text/                      # Text data (editable)
│   ├── systemmsg-e.dat          # System messages
│   ├── npcname-e.dat            # NPC names
│   ├── skillname-e.dat          # Skill names
│   ├── itemname-e.dat           # Item names
│   └── *.dat                    # Other text files
│
├── Textures/                    # Texture packages (.utx)
│   └── *.utx                    # Unreal texture files
│
├── Maps/                        # Map files
│   └── *.unr                    # Unreal map files
│
├── StaticMeshes/                # 3D mesh files
│   └── *.usx                    # Static mesh packages
│
├── Animations/                  # Animation files
│   └── *.ukx                    # Animation packages
│
├── Sounds/                      # Sound files
│   └── *.uax                    # Sound packages
│
└── music/                       # Music files
    └── *.ogg                    # Music tracks
```

---

## L2Text Files

The `L2text/` folder contains editable text files that control in-game strings.

### File Formats

| File | Content |
|------|---------|
| `systemmsg-e.dat` | System messages (combat, errors) |
| `npcname-e.dat` | NPC/monster names |
| `skillname-e.dat` | Skill names and descriptions |
| `itemname-e.dat` | Item names |
| `zonename-e.dat` | Zone names |

### Editing L2Text

1. Files are tab-separated with ID and text
2. Use a specialized L2Text editor or spreadsheet
3. Keep IDs consistent with server

Example `systemmsg-e.dat` format:
```
1	Welcome to the server!
2	You have gained experience.
3	Attack cancelled.
```

---

## Texture Files (.utx)

### Creating/Editing Textures

1. Export from `.utx` using UnrealEd or tools
2. Edit as BMP/DDS/TGA
3. Re-import to UTX

### Common Texture Packages

| Package | Content |
|---------|---------|
| `Lineage2.utx` | Main game textures |
| `InterfacePackage.utx` | UI elements |
| `NewInterface.utx` | Modern UI |
| `LogoTextures.utx` | Server logos |

### Custom Logo

To replace login screen logo:
1. Create 256x256 or 512x512 texture
2. Import to `LogoTextures.utx`
3. Replace `logo` texture

---

## Client Configuration

### L2.ini

Main client settings (in `system/`):

```ini
[Engine.Engine]
GameEngine=l2.war.Engine.L2GameEngine
RenderDevice=D3DDrv.D3DRenderDevice

[URL]
Protocol=l2
ProtocolDescription=Lineage 2

[L2GameInfo]
Host=127.0.0.1
Port=2106
```

### Option.ini

Graphics and audio settings.

---

## Common Tasks

### Change Server IP

Edit `system/L2.ini`:
```ini
[L2GameInfo]
Host=your.server.ip
Port=2106
```

### Add Custom System Message

1. Edit `L2text/systemmsg-e.dat`
2. Add new line with unique ID
3. Reference ID from server code

### Replace Login Logo

1. Create texture in image editor
2. Use UnrealEd to import to UTX
3. Replace in `LogoTextures.utx`

---

## Tools

| Tool | Purpose |
|------|---------|
| UnrealEd | UTX/UNR editing |
| L2Text Editor | Editing .dat files |
| L2Encrypt | Encrypting/decrypting dat |
| UTX Tool | Quick UTX manipulation |

---

## Important Notes

⚠️ **Client/Server Sync**: Many client changes require corresponding server changes:
- NPC names must match server
- Item IDs must match items.xml
- Skill IDs must match skills.xml

⚠️ **Encryption**: Some files are encrypted. Use appropriate tools to decrypt before editing.

⚠️ **File Integrity**: Modified clients may trigger anticheat. Test thoroughly.
