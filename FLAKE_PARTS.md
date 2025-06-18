# Flake-Parts Implementation

This document describes the flake-parts implementation and modular structure of the ngrok NixOS service.

## Overview

The repository provides two flake implementations:

1. **Traditional Flake** (`flake.nix`) - Monolithic approach with templates
2. **Flake-Parts** (`flake-parts.nix`) - Modular approach using flake-parts

## Flake-Parts Structure

### Main Configuration (`flake-parts.nix`)

```nix
{
  imports = [
    ./parts/ngrok-module.nix    # Module exports
    ./parts/dev-shells.nix      # Development environments
    ./parts/nixos-configs.nix   # NixOS configurations
    ./parts/packages.nix        # Package exports
  ];
  
  flake = {
    nixosModules.default = import ./modules/ngrok.nix;
    templates = { ... };        # Template definitions
  };
}
```

### Modular Parts

#### `parts/ngrok-module.nix`
Exports the core ngrok module for use in other flakes:
```nix
flake.nixosModules = {
  default = import ../modules/ngrok.nix;
  ngrok = import ../modules/ngrok.nix;
};
```

#### `parts/dev-shells.nix`
Provides development environments:
- **`default`** - Full development environment with testing tools
- **`ci`** - Minimal CI environment

#### `parts/nixos-configs.nix`
Example NixOS configurations:
- `nixgrok-x86` - x86_64-linux configuration
- `nixgrok-aarch64` - aarch64-linux with VM config
- `example-basic` - Basic template configuration
- `example-advanced` - Advanced template configuration

#### `parts/packages.nix`
Package exports:
- `ngrok` - The ngrok package
- `docs` - Generated documentation
- `vm` - VM build (Linux only)

## Available Templates

### Basic Template
**Path**: `examples/basic/`
**Description**: Simple HTTP tunnel setup
**Features**:
- Single HTTP tunnel on port 8080
- Basic Python web server
- Minimal configuration

```bash
nix flake init -t github:user/nixgrok#basic
```

### Advanced Template  
**Path**: `examples/advanced/`
**Description**: Multi-service setup with security features
**Features**:
- Multiple tunnels (web, admin, API, webhooks, SSH, database)
- Nginx reverse proxy
- PostgreSQL database
- Security headers and IP restrictions
- Circuit breakers and compression

```bash
nix flake init -t github:user/nixgrok#advanced
```

### OAuth Template
**Path**: `examples/oauth/`
**Description**: OAuth-protected services
**Features**:
- Google OAuth (admin panel)
- GitHub OAuth (development tools)
- Microsoft OAuth (enterprise tools)
- Facebook OAuth (marketing tools)
- Public API (no auth)

```bash
nix flake init -t github:user/nixgrok#oauth
```

### Enterprise Template
**Path**: `examples/enterprise/`
**Description**: Production-ready enterprise setup
**Features**:
- OIDC integration
- Mutual TLS authentication
- Compliance features (SOX, PCI DSS)
- Monitoring and alerting
- Security hardening
- File integrity monitoring

```bash
nix flake init -t github:user/nixgrok#enterprise
```

## Usage Patterns

### As a Flake Input

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ngrok-nixos.url = "github:user/nixgrok";
  };

  outputs = { nixpkgs, ngrok-nixos, ... }: {
    nixosConfigurations.myserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ngrok-nixos.nixosModules.default
        {
          services.ngrok = {
            enable = true;
            authToken = "your-token";
            tunnels.web = {
              protocol = "http";
              port = 80;
            };
          };
        }
      ];
    };
  };
}
```

### Using Flake-Parts

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    ngrok-nixos.url = "github:user/nixgrok";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      
      imports = [
        inputs.ngrok-nixos.flakeModules.default
      ];
      
      flake.nixosConfigurations.myserver = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.ngrok-nixos.nixosModules.default
          ./configuration.nix
        ];
      };
    };
}
```

## Development Workflow

### Development Environment

```bash
# Enter development environment
nix develop

# Or with flake-parts
nix develop -f flake-parts.nix
```

### Creating Templates

1. Create template directory in `examples/`
2. Add `flake.nix` and `configuration.nix`
3. Add template to main flake templates section
4. Test template creation

### Testing

```bash
# Test main flake
nix flake check --impure

# Test flake-parts version
nix flake check -f flake-parts.nix --impure

# Show available outputs
nix flake show
```

## Benefits of Flake-Parts

### Modularity
- Split functionality into logical parts
- Easier to maintain and extend
- Better code organization

### Composability
- Mix and match parts as needed
- Reuse parts in other flakes
- Standard patterns across projects

### Extensibility
- Easy to add new parts
- Override specific functionality
- Plugin architecture

### Community
- Follow flake-parts conventions
- Better integration with ecosystem
- Shared patterns and practices

## Migration Guide

### From Traditional Flake

1. Move functionality to `parts/` directory
2. Create `flake-parts.nix` with imports
3. Update development workflows
4. Test both versions during transition

### To Your Project

1. Choose appropriate template
2. Customize for your needs
3. Add your specific services
4. Update authentication/security settings

## Best Practices

### Structure
- Keep parts small and focused
- Use descriptive names
- Document each part's purpose

### Configuration
- Use sensible defaults
- Provide comprehensive options
- Include validation where possible

### Security
- Never commit secrets
- Use proper file permissions
- Validate all inputs

### Testing
- Test on multiple systems
- Validate templates work
- Check cross-compilation

## Troubleshooting

### Common Issues

**Template not found**:
```bash
# Ensure files are added to git
git add examples/
```

**Cross-compilation errors**:
```bash
# Use system-specific builds
nix build --system x86_64-linux
```

**Flake-parts not found**:
```bash
# Add flake-parts input
nix flake lock --update-input flake-parts
```

### Debug Commands

```bash
# Show flake structure
nix flake show

# Check specific template
nix flake check --override-input ngrok-nixos .

# Debug template creation
nix flake init -t .#basic --debug
```