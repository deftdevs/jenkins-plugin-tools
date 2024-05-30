{ ... }:

[
  (
    final: prev: {
      jenkins-plugin-manager = final.callPackage ./pkgs/jenkins-plugin-manager { };
      jenkins-update-center = final.callPackage ./pkgs/jenkins-update-center { };
    }
  )
]
