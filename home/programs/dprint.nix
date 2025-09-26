{pkgs, ...}: {
  home.packages = with pkgs; [
    dprint
  ];

  xdg.configFile."dprint/dprint.json".text = ''
    {
      "markdown": {
        "lineWidth": 120
      },
      "excludes": [],
      "plugins": [
        "https://plugins.dprint.dev/markdown-0.16.1.wasm"
      ]
    }
  '';
}