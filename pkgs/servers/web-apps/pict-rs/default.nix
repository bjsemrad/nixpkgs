{ stdenv
, lib
, fetchFromGitea
, rustPlatform
, makeWrapper
, protobuf
, darwin
, imagemagick
, ffmpeg
, exiftool
, nixosTests
}:

rustPlatform.buildRustPackage rec {
  pname = "pict-rs";
  version = "0.4.6";

  src = fetchFromGitea {
    domain = "git.asonix.dog";
    owner = "asonix";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-nFfGyOxzJZ2U/1FpY64BorRd5yncipsaBbr/TsYnmjM=";
  };

  cargoHash = "sha256-11TyKs+JQiKBzFzGJe5sOllbPVEhchZrsryZp6L2JFo=";

  # needed for internal protobuf c wrapper library
  PROTOC = "${protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${protobuf}/include";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks ];

  postInstall = ''
    wrapProgram "$out/bin/pict-rs" \
        --prefix PATH : "${lib.makeBinPath [ imagemagick ffmpeg exiftool ]}"
  '';

  passthru.tests = { inherit (nixosTests) pict-rs; };

  meta = with lib; {
    description = "A simple image hosting service";
    homepage = "https://git.asonix.dog/asonix/pict-rs";
    license = with licenses; [ agpl3Plus ];
    maintainers = with maintainers; [ happysalada ];
  };
}
