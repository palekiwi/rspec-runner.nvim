{ pkgs, ... }:

pkgs.mkShell {
  name = "rspec.nvim";
  buildInputs =
    with pkgs; [
      luajit
      luajitPackages.busted
      luajitPackages.nlua
      luajitPackages.nui-nvim

      ruby_3_4
      rubyPackages_3_4.rspec
    ];
}
