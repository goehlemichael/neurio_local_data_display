{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [
        gnuplot
        jq
        curl
    ];
  shellHook =
    ''
      chmod +x ../neurio.sh
      # see 'set terminal' section of gnuplot docs
      TERM_NAME="dumb" ../neurio.sh
    '';
}
