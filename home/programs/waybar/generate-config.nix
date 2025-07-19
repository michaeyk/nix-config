{ lib, hostname ? "unknown" }:

let
  baseConfig = builtins.fromJSON (builtins.readFile ./config.jsonc);
  
  # Add mpris to modules-center for gaming machine
  modulesCenter = if hostname == "gaming"
    then ["mpris"]
    else baseConfig.modules-center;
in
  builtins.toJSON (baseConfig // {
    modules-center = modulesCenter;
  })