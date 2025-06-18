{ inputs, ... }:
{
  perSystem = { config, self', inputs', pkgs, system, ... }: {
    packages = {
      default = pkgs.ngrok;
      ngrok = pkgs.ngrok;
      
      # Documentation
      docs = pkgs.stdenv.mkDerivation {
        name = "ngrok-nixos-docs";
        src = ../.;
        buildInputs = [ pkgs.pandoc ];
        buildPhase = ''
          mkdir -p $out
          cp README.md $out/
          cp TESTING_RESULTS.md $out/
          pandoc README.md -o $out/index.html
        '';
        installPhase = "true";
      };
      
      # VM testing (Linux only) - commented out due to cross-compilation issues on macOS
      # } // pkgs.lib.optionalAttrs (system == "aarch64-linux" || system == "x86_64-linux") {
      #   vm = config.nixosConfigurations.nixgrok-aarch64.config.system.build.vm or null;
    };
  };
}