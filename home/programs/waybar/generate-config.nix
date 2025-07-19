{ lib, hostname ? "unknown" }:

let
  baseConfig = builtins.fromJSON (builtins.readFile ./config.jsonc);
  
  # Add mpris to modules-right for gaming machine
  modulesRight = if hostname == "gaming"
    then ["mpris"] ++ baseConfig.modules-right
    else baseConfig.modules-right;
in
  builtins.toJSON (baseConfig // {
    modules-right = modulesRight;
  })