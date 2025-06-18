{ ... }:
{
  flake.nixosModules = {
    default = import ../modules/ngrok.nix;
    ngrok = import ../modules/ngrok.nix;
  };
}