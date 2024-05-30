{
  description = "Jenkins plugin tools";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    flake-utils,
    ...
  }:

  flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = import ./overlays inputs;

      # Nix packages
      pkgs = import nixpkgs { inherit system overlays; };

      # Packages to include in both the dev shell and the Docker image
      packages = with pkgs; [
        bash
        curl
        jenkins-plugin-manager
        jenkins-update-center
        jq
        yq
      ];
    in {
      devShell = pkgs.mkShell {
        name = "Jenkins plugin tools dev shell";
        packages = packages;
      };

      defaultPackage = pkgs.dockerTools.buildLayeredImage {
        name = "jenkins-plugin-tools";
        created = "now";
        contents = packages;
      };
    }
  );
}
