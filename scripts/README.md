# CoreLocationCLI scripts guide

## Quick start

Always run these scripts from the CoreLocationCLI project root directory (using the `./scripts/` prefix). This ensures all build paths are correctly resolved.

0. **Make scripts executable**:

   ```bash
   chmod +x scripts/*.sh  # Add execution permission to all scripts
   ```

1. **Install CoreLocationCLI**:

   ```bash
   ./scripts/install.sh  # Automatically installs via brew or builds from source
   ```

   Note: The install script will use Homebrew if available, or build from source if not.

2. **If you cannot get location permissions, create an app**:
   Only execute this when experiencing permission issues:

   ```bash
   ./scripts/create_app.sh
   ```

   Follow the prompts to authorize the brew-installed version if needed.
   When the app launches, allow location permissions in System Settings.

   For more options and advanced usage:

   ```bash
   ./scripts/create_app.sh -h
   ```

## Script functions

- **install.sh**: Automatically install via brew or build from source
- **create_app.sh**: Resolve permission issues (use only when needed)

If you encounter "(kCLErrorDomain error 0.)" error, try restarting your Wi-Fi as this might help.
