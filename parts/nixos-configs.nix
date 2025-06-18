{ inputs, ... }:
{
  flake.nixosConfigurations = {
    # Basic ngrok configuration for x86_64
    nixgrok-x86 = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../configuration.nix
        ../modules/ngrok.nix
        { nixpkgs.config.allowUnfree = true; }
      ];
    };
    
    # VM-optimized configuration for aarch64
    nixgrok-aarch64 = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ../configuration.nix
        ../vm-config.nix
        ../modules/ngrok.nix
        { nixpkgs.config.allowUnfree = true; }
      ];
    };

    # Example configurations from templates
    example-basic = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../examples/basic/configuration.nix
        ../modules/ngrok.nix
        { nixpkgs.config.allowUnfree = true; }
      ];
    };

    example-advanced = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../examples/advanced/configuration.nix
        ../modules/ngrok.nix
        { nixpkgs.config.allowUnfree = true; }
      ];
    };
  };
}