{ pkgs, ... }:

pkgs.mkShell {
  name = "rspec-runner";
  buildInputs =
    with pkgs; [
      luajit
      luajitPackages.busted
      luajitPackages.nlua
      luajitPackages.nui-nvim

      # (vimPlugins.nvim-treesitter.withPlugins (p: [ p.ruby ]))
      vimPlugins.nvim-treesitter
      vimPlugins.nvim-treesitter-parsers.ruby

      ruby_3_4
      rubyPackages_3_4.rspec
    ];
}
