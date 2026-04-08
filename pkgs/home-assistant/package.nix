{
  buildCatppuccinPort,
  whiskers,
}:

buildCatppuccinPort {
  port = "home-assistant";

  nativeBuildInputs = [ whiskers ];

  buildPhase = ''
    runHook preBuild

    whiskers home-assistant.tera

    runHook postBuild
  '';
}
