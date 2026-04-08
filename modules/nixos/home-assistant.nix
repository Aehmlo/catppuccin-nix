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
      lightFlavor = lib.mkOption {
        type = catppuccinLib.types.flavor;
        default = config.catppuccin.home-assistant.flavor;
        description = ''
          Catppuccin flavor for Home Assistant light mode.

          Takes priority over {option}`catppuccin.home-assistant.flavor`.
        '';
        example = "latte";
      };
      darkFlavor = lib.mkOption {
        type = catppuccinLib.types.flavor;
        default = config.catppuccin.home-assistant.flavor;
        description = ''
          Catppuccin flavor for Home Assistant dark mode.

          Takes priority over {option}`catppuccin.home-assistant.flavor`.
        '';
        example = "macchiato";
      };
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
        alias = "Catppuccin default themes";
        id = "catppuccin_default_theme";
        description = "Sets the default frontend themes at startup.";
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
                inherit (cfg) accent;
                flavor = cfg.lightFlavor;
              };
              name_dark = mkHassThemeName {
                inherit (cfg) accent;
                flavor = cfg.darkFlavor;
              };
            };
        };
      };

    };
}
