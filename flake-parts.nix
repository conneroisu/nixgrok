{
  description = "NixOS ngrok service with flake-parts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      
      imports = [
        ./parts/ngrok-module.nix
        ./parts/dev-shells.nix
        ./parts/nixos-configs.nix
        ./parts/packages.nix
      ];

      flake = {
        # Export the ngrok module for use in other flakes
        nixosModules.default = import ./modules/ngrok.nix;
        nixosModules.ngrok = import ./modules/ngrok.nix;
        
        # Flake templates
        templates = {
          basic = {
            path = ./examples/basic;
            description = "Basic ngrok service configuration";
          };
          
          advanced = {
            path = ./examples/advanced;
            description = "Advanced ngrok service with all features";
          };
          
          oauth = {
            path = ./examples/oauth;
            description = "OAuth-protected ngrok tunnels";
          };
          
          enterprise = {
            path = ./examples/enterprise;
            description = "Enterprise ngrok setup with security features";
          };
        };
      };
    };
}