{ inputs, ... }:
{
  perSystem = { config, self', inputs', pkgs, system, ... }: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        # VM and testing tools
        qemu
        socat
        expect
        curl
        jq
        python3
        
        # ngrok
        ngrok
        
        # Development tools
        git
        nix-output-monitor
      ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
        # macOS specific tools can go here
      ];
      
      shellHook = ''
        echo "🚀 ngrok NixOS Service Development Environment"
        echo "============================================="
        echo "System: ${system}"
        echo ""
        echo "Available commands:"
        echo "  nix flake check           - Validate flake"
        echo "  ./scripts/test-quick.sh   - Quick ngrok test"
        echo "  ./scripts/build-vm.sh     - Build test VM"
        echo ""
        echo "Examples:"
        echo "  nix flake init -t .#basic      - Basic setup"
        echo "  nix flake init -t .#advanced   - Advanced features"
        echo "  nix flake init -t .#oauth      - OAuth setup"
        echo "  nix flake init -t .#enterprise - Enterprise setup"
        echo ""
      '';
    };
    
    devShells.ci = pkgs.mkShell {
      buildInputs = with pkgs; [
        nix
        git
        curl
        jq
      ];
      
      shellHook = ''
        echo "CI Environment for ngrok NixOS Service"
      '';
    };
  };
}