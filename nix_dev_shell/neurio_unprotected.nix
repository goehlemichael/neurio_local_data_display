{ pkgs ? import <nixpkgs> {} }:
 let
   nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-23.11";
   pkgs = import nixpkgs { config = {}; overlays = []; };
 in
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [
        gnuplot
        jq
        curl
    ];
  shellHook =
    ''
      chmod +x ../neurio_no_pw_endpoint.sh
      # see 'set terminal' section of gnuplot docs
      TERM_NAME="dumb" ../neurio_no_pw_endpoint.sh
    '';
}
