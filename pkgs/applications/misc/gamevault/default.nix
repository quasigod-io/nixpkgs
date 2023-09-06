{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  pkg-config,
  vips,
  python3,
}:
buildNpmPackage rec {
  pname = "gamevault-backend";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "Phalcode";
    repo = "gamevault-backend";
    rev = version;
    hash = "sha256-aRkq6LP7L+ZIS5w2zVYXOMqkgkvzU8Eo9Zr8sh1//9A=";
  };

  patches = [./bin.patch];

  npmDepsHash = "sha256-k2FjXRiWdRPQ27nK+QcLoTGzsa1lyxG9XiltmcKwMMQ=";
  npmFlags = ["--legacy-peer-deps"];
  # makeCacheWritable = true;

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    vips
  ];

  meta = with lib; {
    description = "Backend for the self-hosted gaming platform for 'alternatively obtained' games";
    homepage = "https://github.com/Phalcode/gamevault-backend";
    changelog = "https://github.com/Phalcode/gamevault-backend/blob/${src.rev}/CHANGELOG.md";
    license = licenses.cc-by-nc-sa-40;
    maintainers = with maintainers; [];
  };
}
