{
  description = "NixOS configuration with ngrok service";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixos-generators }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages.default = pkgs.ngrok;
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            qemu
            socat
            expect
            curl
            jq
            ngrok
            python3
          ] ++ lib.optionals stdenv.isDarwin [
            # UTM is not in nixpkgs, but QEMU works on macOS
          ];
          
          shellHook = ''
            echo "VM Testing Environment for ${system}"
            echo "Available commands:"
            echo "  ./scripts/start-vm.sh    - Start test VM"
            echo "  ./scripts/test-ngrok.sh  - Run ngrok tests"
            echo "  ./scripts/build-vm.sh    - Build VM image"
          '';
        };
      }
    ) // {
      nixosModules.ngrok = import ./modules/ngrok.nix;
      
      nixosConfigurations = {
        nixgrok-x86 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            self.nixosModules.ngrok
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
        
        nixgrok-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./configuration.nix
            ./vm-config.nix
            self.nixosModules.ngrok
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
      };

      # VM system for testing
      packages.aarch64-linux.vm = self.nixosConfigurations.nixgrok-aarch64.config.system.build.vm;

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
}
