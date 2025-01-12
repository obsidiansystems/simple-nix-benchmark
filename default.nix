{ pkgs ? import ./nixpkgs {}
, number ? 10
, length ? 512*1024*1024
, key ? "1234"
}:
let ids = builtins.genList (n: n + 1) number;
    mkItem = n: pkgs.runCommand "item" {
      buildInputs = with pkgs; [
        coreutils
        openssl
        gzip
      ];
    } ''
      mkdir $out
      dd if=/dev/zero bs=${toString length} count=1 | openssl enc -aes-256-cbc -pass pass:${key + "-" + toString n} | gzip > $out/item-${toString n}.gz
    '';
in
pkgs.runCommand "assemble" {
  items = map mkItem ids;
  buildInputs = with pkgs; [
    coreutils
  ];
} ''
  mkdir $out
  for x in $items ; do
    sha256sum $x/item-* | awk '{print $1}' >> $out/sums
  done
''
