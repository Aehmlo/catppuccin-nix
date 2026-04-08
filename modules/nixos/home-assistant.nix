{ catppuccinLib }:
{
  lib,
  config,
  ...
}:
let
  inherit (config.catppuccin) sources;
in
{
  options.catppuccin.home-assistant = (
    (catppuccinLib.mkCatppuccinOption {
      name = "home-assistant";
      accentSupport = true;
    })
    // {
      setDefaultAtStartup =
        (lib.mkEnableOption "setting the default theme at Home Assistant startup")
        // {
          default = true;
          example = false;
        };
    }
  );

  config.services.home-assistant.config =
    let
      cfg = config.catppuccin.home-assistant;
      inherit (lib) singleton toSentenceCase;
    in
    lib.mkIf (cfg.enable && config.services.home-assistant.enable) {

      frontend.themes = "!include_dir_merge_named ${sources.home-assistant}";

      "automation catppuccin" = lib.mkIf cfg.setDefaultAtStartup {
        alias = "Catppuccin default theme";
        id = "catppuccin_default_theme";
        description = "Sets the default frontend theme to ${catppuccinLib.mkFlavorName cfg.flavor} at startup.";
        mode = "single";
        triggers = singleton {
          trigger = "homeassistant";
          event = "start";
        };
        actions = singleton {
          action = "frontend.set_theme";
          data =
            let
              mkHassThemeName =
                {
                  flavor,
                  accent,
                }:
                # n.b. the packaged theme names use ASCII characters (so no é in "latté")
                "Catppuccin ${toSentenceCase flavor} ${toSentenceCase accent}";
            in
            {
              name = mkHassThemeName {
                inherit (cfg) flavor accent;
              };
              name_dark = "none";
            };
        };
      };

    };
}
