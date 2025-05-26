# Crate 🚀

## Synopsis

**Crate** is a modern PowerShell-based Windows ISO provisioning tool that provides an intuitive CLI interface for mounting, provisioning, and dismounting Windows ISO images with updates and language packs.

## Description

Crate streamlines the process of Windows ISO management by offering:

- **Modern CLI Interface**: Beautiful, interactive terminal-based experience with emojis and colors
- **ISO Mounting/Dismounting**: Seamless Windows ISO handling
- **Update Provisioning**: Integration with Windows Update Catalog and local update files
- **Language Pack Management**: Easy addition of Windows language packs
- **Automated Workflows**: Configuration profiles for repeatable operations
- **Comprehensive Logging**: Detailed operation tracking with log rotation
- **Error Recovery**: Rollback capabilities and resume-after-interruption features

## Why

Windows administrators often need to create customized ISO images with the latest updates and language packs. Traditional methods involve complex manual processes with multiple tools. Crate simplifies this by providing a unified, modern interface that automates the entire workflow while maintaining full control and visibility.

## Getting Started

### Prerequisites

- **PowerShell 7.4+** (required)
- **Windows 10/11 or Windows Server** (required)
- **Administrative privileges** (required)
- **DISM** (included with Windows)
- **OSCDIMG** (Windows ADK - for ISO creation)
- **Minimum 20GB free disk space**

### Installation

```powershell
# Clone the repository
git clone https://github.com/mchave3/Crate.git
cd Crate

# Import the module
Import-Module .\src\Crate\Crate.psm1

# Or install from PowerShell Gallery (when published)
Install-Module -Name Crate -Scope CurrentUser
```

### Quick start

#### Example 1: Interactive Mode

```powershell
# Start Crate with interactive menu (run as Administrator)
Start-Crate
```

This launches the main menu with options for:
- 📀 Mount Windows ISO
- 🔄 Provision Updates
- 🌐 Add Language Packs
- 💿 Create Provisioned ISO
- 📊 View Current Status
- ⚙️ Configuration
- 📋 View Logs
- 🧹 Cleanup Workspace

#### Example 2: Custom Workspace

```powershell
# Use a custom workspace location
Start-Crate -WorkspacePath "D:\CrateWorkspace"
```

#### Example 3: Automated Mode (Future)

```powershell
# Run with predefined configuration profile
Start-Crate -ConfigProfile "Windows11Latest" -AutoMode
```

## Architecture

```
Crate/
├── Core/                   # Core functionality (logging, config, validation)
├── ISO/                    # ISO mounting and dismounting
├── WIM/                    # WIM file manipulation
├── Updates/                # Windows Update management
├── LanguagePacks/          # Language pack handling
├── UI/                     # Modern terminal interface
├── Validation/             # Integrity checking
├── Workflows/              # Operation orchestration
└── Configuration/          # Profile management
```

## Workspace Structure

Crate creates a structured workspace at `C:\ProgramData\Crate`:

```
C:\ProgramData\Crate/
├── Config/                 # Settings and profiles
├── Workspace/              # Temporary working files
│   ├── ISO/               # Mounted ISO images
│   ├── WIM/               # WIM files being processed
│   └── Temp/              # Temporary files
├── Downloads/              # Updates and language packs
├── Logs/                   # Operation logs
└── Backup/                 # Rollback data
```

## Features

### ✨ Current Features
- ✅ Modern CLI interface with interactive menus
- ✅ Administrative privilege validation
- ✅ Workspace initialization and management
- ✅ Comprehensive logging with rotation
- ✅ PowerShell 7.4+ requirement validation
- ✅ Modular architecture for easy maintenance

### 🚧 Planned Features
- 🔄 ISO mounting and dismounting
- 🔄 Windows Update provisioning
- 🔄 Language pack installation
- 🔄 Automated workflows with profiles
- 🔄 Progress bars and status indicators
- 🔄 Configuration management
- 🔄 Log viewer and analysis
- 🔄 Workspace cleanup utilities

## Development Status

**Current Version**: 25.5.26.1 (May 26, 2025)

This project is in active development. The foundation and architecture are complete, with core features being implemented incrementally.

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Follow PowerShell best practices
4. Add appropriate tests
5. Submit a pull request

## Build System

Crate uses Invoke-Build for automation:

```powershell
# Run default build
Invoke-Build

# Run tests
Invoke-Build -Task Test

# Run with code coverage
Invoke-Build -Task DevCC

# Clean workspace
Invoke-Build -Task Clean
```

## Author

**Mickaël CHAVE**

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Links

- [Repository](https://github.com/mchave3/Crate)
- [Documentation](docs/)
- [Issues](https://github.com/mchave3/Crate/issues)
