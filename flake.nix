# This flake collates all my host flakes together for convenienc0
{
  inputs = {
    nixpkgs = { 
      url = "https://flakehub.com/f/NixOS/nixpkgs/*"
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Our secret keeping scheme
    agenix = { 
      url = "github:ryantm/agenix";
      # optional, not necessary for the module
      #inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";
      # optionally choose not to download darwin deps (saves some resources on Linux)
      inputs.agenix.inputs.darwin.follows = "";
      
    };
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # for experimenting with
    git-agecrypt.url = "github.com:vlaci/git-agecrypt":
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { agenix, sops-nix, git-agecrypt ... }: rec {
    nixosModules = {
      # Import me to import Agenix and it's bare minimum configuration
      default = { pkgs, ... }:
        let
          keyPath = "/key";
          secretPath = "${keyPath}/secrets";
          agenixPath = "${keyPath}/agenix";
          identityPath = "${agenixPath}/keys";
          generationPath = "${agenixPath}/generations";

          # Create paths to the Agenix keys that will be used to decrypt secrets
          keys = publicKeys;
          users = keys.users;
          machines = keys.machines;
          identityPaths = (map
            (name: "${identityPath}/${name}.agenix")
            ((builtins.attrNames users) ++ (builtins.attrNames machines)));
        in
        {
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
            # Where the secrets will by symlinked/deployed to
            # Where applications should look for them
            secretsDir = secretPath;
            # Where the secrets per generation are created
            # (and then symlinked to secretsDir)
            secretsMountPoint = generationPath;
            # Where to look for keys to decrypt secrets
            inherit identityPaths;
          };
        };
    };
    # Public keys can be kept here, so they only need to be updated in one place
    # These keys encrypt all other secrets
    publicKeys = {
      machines = {
        tachi = "";
        anubis = "";
        scopuli = "";
        lnx = "";
        lnb = "";
        lnw = "";
      };
      users = {
        lessuseless = "";
      };
    };
  };
}
