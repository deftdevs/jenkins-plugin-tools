{ lib
, stdenv
, fetchurl
, jre
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "jenkins-plugin-manager";
  version = "2.13.0";

  src = fetchurl {
    url = "https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${version}/${pname}-${version}.jar";
    hash = "sha256-ztMLyqMyCUeK1DpvAuXiF0FaHzo3so0tBE23s+lgBOU=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/${pname}

    install -Dm644 $src $out/share/${pname}/${pname}.jar

    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/${pname}/${pname}.jar"
  '';

  meta = with lib; {
    homepage = "https://github.com/jenkinsci/plugin-installation-manager-tool";
    description = "Jenkins plugin manager CLI tool";
    license = licenses.mit;
    mainProgram = "${pname}";
    maintainers = [ maintainers.pathob ];
  };
}
