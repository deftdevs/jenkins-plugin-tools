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
      # Nix packages
      pkgs = import nixpkgs { inherit system; };

      jenkins-plugin-manager = pkgs.callPackage ./pkgs/jenkins-plugin-manager { };

      jenkins-update-center = pkgs.callPackage ./pkgs/jenkins-update-center { };

      # Packages to include in both the dev shell and the Docker image
      packages = with pkgs; [
        bash
        coreutils
        curl
        gnused
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
        created = builtins.substring 0 8 self.lastModifiedDate;
        contents = packages;
      };

      packages.jenkins-plugin-manager = jenkins-plugin-manager;

      packages.jenkins-update-center = jenkins-update-center;
    }
  );
}
