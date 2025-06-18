{
  description = "OAuth-protected ngrok tunnels example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    ngrok-nixos.url = "github:yourusername/nixgrok"; # Replace with actual repo
    # Or for local development:
    # ngrok-nixos.url = "path:../..";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      
      flake.nixosConfigurations.oauth-server = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.ngrok-nixos.nixosModules.default
          ./configuration.nix
        ];
      };
    };
}