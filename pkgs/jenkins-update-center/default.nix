{ lib
, fetchFromGitHub
, jre
, makeWrapper
, maven
}:

maven.buildMavenPackage rec {
  pname = "jenkins-update-center";
  # Also update `mvnHash` below when updating the version
  version = "3.16";

  src = fetchFromGitHub rec {
    owner = "jenkins-infra";
    repo = "update-center2";
    rev = "${repo}-${version}";
    hash = "sha256-lZVkpyB2QGZmBoBWufcRmjAi+OsFv3m7OyCNfqFSBwc=";
  };

  # Use `lib.fakeHash` to let failing build tell you the actual hash
  mvnHash = "sha256-XNDp9QvTwHkdGK9RjnhDKk/0XrzKKz9OTPM7R6ezGEM=";

  # Build package without tests that are trying to access the internet,
  # which is not available as the build happens in a sandbox
  mvnParameters = "-Dtest=\!MaintainersSourceTest,\!WarningsTest";

  # Patch bouncycastle dependency until the this PR is merged and released
  # https://github.com/jenkins-infra/update-center2/pull/785
  patches = [ ./bouncycastle-update.patch ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/${pname}

    for f in target/update-center2-${version}-bin/*; do
      install -Dm644 $f $out/share/${pname}
    done

    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/${pname}/update-center2-${version}.jar"
  '';

  meta = {
    homepage = "https://github.com/jenkins-infra/update-center2";
    description = "Jenkins Update Center backend";
    mainProgram = "${pname}";
    maintainers = with lib.maintainers; [ pathob ];
  };
}
