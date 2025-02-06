# This flake collates all my host flakes together for convenienc0
{
  inputs = {
    # Our secret keeping scheme
    agenix.url = "github:ryantm/agenix";
  };
  outputs =
    { agenix, ... }:
    {
      nixosModules = {
        # Import me to import Agenix and it's bare minimum configuration
        default = { pkgs, ... }: {
          imports = [
            agenix.nixosModules.default
          ];
          # Install secret management tooling
          environment.systemPackages = [
            # age key generation and management
            pkgs.age
            agenix.packages.${pkgs.system}.default
          ];
          # We will always store our secrets on a removable 'key'
          age = {
            secretsDir = "/key/secrets";
            secretsMountPoint = "/key/agenix/generations";
          };
        };
      };
      # Public keys can be kept here, so they only need to be updated in one place
      # These keys decrypt all other secrets
      publicKeys = {
        machines = {
          nyaa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtHIPfa2+AQGIHZcBRLgkIx+3mhwEt/zf5ClP2AVvZ+ nyaa@machine";
          spark = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDnpWeIBR+QCwclhSqSDKTsYCLYPX0b38lYnKPYBEMM spark@machine";
          archive = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6GH/nzYFaruIZ9ZORbBhYEzTHBnrCZXSJUK2rrs1jL archive@machine";
        };
        users = {
          crow = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTsYcLV5djsXoISRIysYrbHOnPHt3SIqtXdiWIJ+m0Y crow@agenix";
        };
      };
    };
}
