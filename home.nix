{ inputs, config, pkgs, isDesktop, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "user";
  home.homeDirectory = "/home/user";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [ whois
      (lib.hiPrio uutils-coreutils-noprefix)
      p7zip
      inputs.fh.packages.${system}.default
    ] ++ lib.optionals (isDesktop) [
      tor-browser
      jellyfin-media-player
      wl-clipboard-rs
      grimblast
    ] ++ lib.optionals (isDesktop) [
      (pkgs.writeShellApplication {
        name = "hyprland.sh";
        text = ''
          uwsm app Hyprland
        '';
      })
    ]
    ++ lib.optionals (!isDesktop) [ kitty.terminfo ];

  home.shell.enableBashIntegration = true;
  home.shell.enableNushellIntegration = true;

  programs.home-manager.enable = true;
  services.home-manager = {
    autoExpire.enable = true;
    autoExpire.store.cleanup = true;
  };

  programs.ripgrep.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "cyberworm-uk";
    userEmail = "93949496+cyberworm-uk@users.noreply.github.com";
  };

  programs.starship = {
    enable = true;
    settings = {
      hostname = {
        ssh_only = false;
      };
    };
  };

  programs.bash = {
    enable = true;
    enableVteIntegration = true;
    sessionVariables = {
      PAGER = "less";
      LESSSECURE = "1";
      LESSHISTFILE = "-";
      HISTFILE = "/dev/null";
    };
  };

  programs.nushell = {
    enable = true;
    extraConfig =
    ''
      let carapace_completer = {|spans|
        carapace $spans.0 nushell ...$spans | from json
      }
      $env.config.completions.external.completer = $carapace_completer
      $env.config = ($env.config | upsert hooks.env_change.PWD {|config|
        let val = ($config | get -i hooks.env_change.PWD)
        if $val == null {
          $val | append {|| ${pkgs.direnv}/bin/direnv export json | from json | default {} | load-env }
        } else {
          [
            {|| ${pkgs.direnv}/bin/direnv export json | from json | default {} | load-env }
          ]
        }
      })
      $env.config.hooks.command_not_found = {
        |command_name|
        print (command-not-found $command_name | str trim)
      }
    '';
    settings = {
      show_banner = false;
      completions = {
        algorithm = "fuzzy";
        case_sensitive = false;
        external = {
          enable = true;
          max_results = 100;
        };
      };
      edit_mode = "vi";
      buffer_editor = "nvim";
    };
    plugins = with pkgs.nushellPlugins; [ formats net ];
  };

  programs.carapace.enable = true;

  programs.kitty.enable = isDesktop; 

  wayland.windowManager.hyprland = pkgs.lib.mkIf isDesktop {
    enable = true;
    settings = let
      toggle = program: let
        prog = builtins.substring 0 14 program;
      in "pkill ${prog} || uwsm app -- ${program}";

      runOnce = program: "pgrep ${program} || uwsm app -- ${program}";
      run = program: "uwsm app -- ${program}";
    in {
      "$mod" = "SUPER";
      input = {
        kb_layout = "gb";
        kb_options = "caps:escape";
        follow_mouse = 1;
        accel_profile = "flat";
        tablet.output = "current";
      };
      bindr = [
        # launcher
        "$mod, SUPER_L, exec, ${toggle "anyrun"}"
      ];
      bind =
      [
        "$mod, Return, exec, ${run "kitty"}"
        "$mod SHIFT, E, exec, pkill Hyprland"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen,"
        "$mod, G, togglegroup,"
        "$mod SHIFT, N, changegroupactive, f"
        "$mod SHIFT, P, changegroupactive, b"
        "$mod, R, togglesplit,"
        "$mod, T, togglefloating,"
        "$mod, P, pseudo,"
        "$mod ALT, , resizeactive,"
        "$mod, L, exec, loginctl lock-session"
        "$mod, Escape, exec, ${toggle "wlogout"} -p layer-shell"
        ", Print, exec, GRIMBLAST_HIDE_CURSOR=0 grimblast copy area"
      ] ++ (
        builtins.concatLists  (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        )
        9)
      );
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ]; 
      bindl = [
        # media controls
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"

        # volume
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];
      bindle = [
        # volume
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%-"

        # backlight
        ", XF86MonBrightnessUp, exec, brillo -q -u 300000 -A 5"
        ", XF86MonBrightnessDown, exec, brillo -q -u 300000 -U 5"
      ];

      windowrulev2 = [
        "float, class:^(firefox)$"
        "float, class:^(Tor Browser)$"
        "float, title:^(Picture-in-Picture|Jellyfin Media Player)$"
        "pin, title:^(Picture-in-Picture|Jellyfin Media Player)$"
      ];
    };
  };

  programs.hyprlock.enable = isDesktop;

  programs.hyprpanel = pkgs.lib.mkIf isDesktop {
    enable = true;
    settings = {
      scalingPriority = "both";
      tear = true;
      menus.transition = "crossfade";
      theme.bar.scaling = 80;
      theme.notification.scaling = 80;
      theme.osd.scaling = 80;
      theme.bar.menus.menu.dashboard.scaling = 80;
      theme.bar.menus.menu.dashboard.confirmation_scaling = 80;
      theme.bar.menus.menu.media.scaling = 80;
      theme.bar.menus.menu.volume.scaling = 80;
      theme.bar.menus.menu.network.scaling = 80;
      theme.bar.menus.menu.bluetooth.scaling = 80;
      theme.bar.menus.menu.battery.scaling = 80;
      theme.bar.menus.menu.clock.scaling = 80;
      theme.bar.menus.menu.notifications.scaling = 80;
      theme.bar.menus.menu.power.scaling = 80;
      theme.tooltip.scaling = 80;
      bar.clock.format = "%H:%M:%S";
      bar.layouts = {
        "*" = {
          left = [
            "workspaces"
            "notifications"
            "netstat"
          ];
          middle = [
            "cpu"
            "ram"
            "storage"
            "cputemp"
          ];
          right = [
            "volume"
            "network"
            "bluetooth"
            "clock"
            "hypridle"
            "power"
          ];
        };
      };
      menus.clock.time.military = true;
      menus.clock.weather.enabled = false;
    };
  };

  services.hypridle = pkgs.lib.mkIf isDesktop {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
        {
          timeout = 360;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.spotify-player = pkgs.lib.mkIf isDesktop {
    enable = true;
    settings = {
      client_id_command = {
        command = "cat";
        args = [ "${config.sops.templates.spotify-client-id.path}" ];
      };
    };
  };

  services.hyprpolkitagent.enable = isDesktop;

  programs.anyrun = pkgs.lib.mkIf isDesktop {
    enable = true;
    config.plugins =
      with inputs.anyrun.packages.${pkgs.system};
      [ applications shell ];
  };

  services.playerctld.enable = isDesktop;

  programs.firefox = pkgs.lib.mkIf isDesktop {
    enable = true;
    profiles.default.containers = {
      social.id = 1;
      media.id = 2;
      research.id = 3;
    };
    policies = {
      Cookies = {
        Behavior = "reject-foreign";
        BehaviorPrivateBrowsing = "reject-foreign";
      };
      HttpsOnlyMode = "enabled";
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DNSOverHTTPS = {
        Enabled = false;
      };
      NetworkPrediction = false;
      DisableFirefoxAccounts = true;
      NewTabPage = false;
      Preferences = {
        "browser.privatebrowsing.autostart" = { Value = true; Status = "locked"; };
        "geo.enabled" = { Value = false; Status = "locked"; };
        "app.normandy.api_url" = { Value = ""; Status = "locked"; };
        "app.normandy.enabled" = { Value = false; Status = "locked"; };
        "app.shield.optoutstudies.enabled" = { Value = false; Status = "locked"; };
        "beacon.enabled" = { Value = false; Status = "locked"; };
        "breakpad.reportURL" = { Value = ""; Status = "locked"; };
        "browser.aboutConfig.showWarning" = { Value = false; Status = "locked"; };
        "browser.crashReports.unsubmittedCheck.autoSubmit" = { Value = false; Status = "locked"; };
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = { Value = false; Status = "locked"; };
        "browser.crashReports.unsubmittedCheck.enabled" = { Value = false; Status = "locked"; };
        "browser.fixup.alternate.enabled" = { Value = false; Status = "locked"; };
        "browser.newtab.preload" = { Value = false; Status = "locked"; };
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = { Value = false; Status = "locked"; };
        "browser.newtabpage.enhanced" = { Value = false; Status = "locked"; };
        "browser.newtabpage.introShown" = { Value = true; Status = "locked"; };
        "browser.safebrowsing.appRepURL" = { Value = ""; Status = "locked"; };
        "browser.safebrowsing.blockedURIs.enabled" = { Value = false; Status = "locked"; };
        "browser.safebrowsing.downloads.enabled" = { Value = false; Status = "locked"; };
        "browser.safebrowsing.downloads.remote.enabled" = { Value = false; Status = "locked"; };
        "browser.safebrowsing.downloads.remote.url" = { Value = ""; Status = "locked"; };
        "browser.safebrowsing.enabled" = { Value = false; Status = "locked"; };
        "browser.safebrowsing.malware.enabled" = { Value = false; Status = "locked"; };
        "browser.safebrowsing.phishing.enabled" = { Value = false; Status = "locked"; };
        "browser.search.suggest.enabled" = { Value = false; Status = "locked"; };
        "browser.selfsupport.url" = { Value = ""; Status = "locked"; };
        "browser.send_pings" = { Value = false; Status = "locked"; };
        "browser.sessionstore.privacy_level" = { Value = 0; Status = "locked"; };
        "browser.startup.homepage_override.mstone" = { Value = "ignore"; Status = "locked"; };
        "browser.tabs.crashReporting.sendReport" = { Value = false; Status = "locked"; };
        "browser.urlbar.groupLabels.enabled" = { Value = false; Status = "locked"; };
        "browser.urlbar.quicksuggest.enabled" = { Value = false; Status = "locked"; };
        "browser.urlbar.speculativeConnect.enabled" = { Value = false; Status = "locked"; };
        "browser.urlbar.trimURLs" = { Value = false; Status = "locked"; };
        "datareporting.healthreport.service.enabled" = { Value = false; Status = "locked"; };
        "datareporting.healthreport.uploadEnabled" = { Value = false; Status = "locked"; };
        "datareporting.policy.dataSubmissionEnabled" = { Value = false; Status = "locked"; };
        "device.sensors.ambientLight.enabled" = { Value = false; Status = "locked"; };
        "device.sensors.enabled" = { Value = false; Status = "locked"; };
        "device.sensors.motion.enabled" = { Value = false; Status = "locked"; };
        "device.sensors.orientation.enabled" = { Value = false; Status = "locked"; };
        "device.sensors.proximity.enabled" = { Value = false; Status = "locked"; };
        "dom.battery.enabled" = { Value = false; Status = "locked"; };
        "dom.private-attribution.submission.enabled" = { Value = false; Status = "locked"; };
        "dom.security.https_only_mode" = { Value = true; Status = "locked"; };
        "dom.security.https_only_mode_ever_enabled" = { Value = true; Status = "locked"; };
        "dom.webaudio.enabled" = { Value = false; Status = "locked"; };
        "experiments.activeExperiment" = { Value = false; Status = "locked"; };
        "experiments.enabled" = { Value = false; Status = "locked"; };
        "experiments.manifest.uri" = { Value = ""; Status = "locked"; };
        "experiments.supported" = { Value = false; Status = "locked"; };
        "extensions.getAddons.cache.enabled" = { Value = false; Status = "locked"; };
        "extensions.greasemonkey.stats.optedin" = { Value = false; Status = "locked"; };
        "extensions.greasemonkey.stats.url" = { Value = ""; Status = "locked"; };
        "extensions.pocket.enabled" = { Value = false; Status = "locked"; };
        "extensions.shield-recipe-client.api_url" = { Value = ""; Status = "locked"; };
        "extensions.shield-recipe-client.enabled" = { Value = false; Status = "locked"; };
        "media.autoplay.default" = { Value = 1; Status = "locked"; };
        "media.autoplay.enabled" = { Value = false; Status = "locked"; };
        "media.navigator.enabled" = { Value = false; Status = "locked"; };
        "media.peerconnection.enabled" = { Value = false; Status = "locked"; };
        "media.video_stats.enabled" = { Value = false; Status = "locked"; };
        "network.IDN_show_punycode" = { Value = true; Status = "locked"; };
        "network.allow-experiments" = { Value = false; Status = "locked"; };
        "network.cookie.cookieBehavior" = { Value = 1; Status = "locked"; };
        "network.dns.disablePrefetch" = { Value = true; Status = "locked"; };
        "network.dns.disablePrefetchFromHTTPS" = { Value = true; Status = "locked"; };
        "network.http.referer.spoofSource" = { Value = true; Status = "locked"; };
        "network.http.speculative-parallel-limit" = { Value = 0; Status = "locked"; };
        "network.predictor.enable-prefetch" = { Value = false; Status = "locked"; };
        "network.predictor.enabled" = { Value = false; Status = "locked"; };
        "network.prefetch-next" = { Value = false; Status = "locked"; };
        "network.trr.mode" = { Value = 5; Status = "locked"; };
        "privacy.donottrackheader.enabled" = { Value = true; Status = "locked"; };
        "privacy.donottrackheader.value" = { Value = 1; Status = "locked"; };
        "privacy.globalprivacycontrol.enabled" = { Value = true; Status = "locked"; };
        "privacy.globalprivacycontrol.functionality.enabled" = { Value = true; Status = "locked"; };
        "privacy.query_stripping" = { Value = true; Status = "locked"; };
        "privacy.resistFingerprinting" = { Value = true; Status = "locked"; };
        "privacy.trackingprotection.cryptomining.enabled" = { Value = true; Status = "locked"; };
        "privacy.trackingprotection.enabled" = { Value = true; Status = "locked"; };
        "privacy.trackingprotection.fingerprinting.enabled" = { Value = true; Status = "locked"; };
        "privacy.trackingprotection.pbmode.enabled" = { Value = true; Status = "locked"; };
        "privacy.usercontext.about_newtab_segregation.enabled" = { Value = true; Status = "locked"; };
        "security.ssl.disable_session_identifiers" = { Value = true; Status = "locked"; };
        "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSite" = { Value = false; Status = "locked"; };
        "signon.autofillForms" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.archive.enabled" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.bhrPing.enabled" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.cachedClientID" = { Value = ""; Status = "locked"; };
        "toolkit.telemetry.enabled" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.firstShutdownPing.enabled" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.hybridContent.enabled" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.newProfilePing.enabled" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.prompted" = { Value = 2; Status = "locked"; };
        "toolkit.telemetry.rejected" = { Value = true; Status = "locked"; };
        "toolkit.telemetry.reportingpolicy.firstRun" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.server" = { Value = ""; Status = "locked"; };
        "toolkit.telemetry.shutdownPingSender.enabled" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.unified" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.unifiedIsOptIn" = { Value = false; Status = "locked"; };
        "toolkit.telemetry.updatePing.enabled" = { Value = false; Status = "locked"; };
        "webgl.disabled" = { Value = true; Status = "locked"; };
        "webgl.renderer-string-override" = { Value = " "; Status = "locked"; };
        "webgl.vendor-string-override" = { Value = " "; Status = "locked"; };
        "browser.ml.chat.enabled" = { Value = false; Status = "locked";};
      };
      ExtensionSettings = {
        "*" = {
          "private_browsing" = true;
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          "installation_mode" = "force_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          "private_browsing" = true;
        };
        "uBlock0@raymondhill.net" = {
          "installation_mode" = "force_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          "private_browsing" = true;
        };
        "{b743f56d-1cc1-4048-8ba6-f9c2ab7aa54d}" = {
          "installation_mode" = "force_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/dracula-dark-colorscheme/latest.xpi";
          "private_browsing" = true;
        };
        "@testpilot-containers" = {
          "installation_mode" = "force_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
          "private_browsing" = true;
        };
      };
      PasswordManagerEnabled = false;
    };
  };

  programs.nixvim = {
    enable = true;
    colorschemes.dracula-nvim.enable = true;
    plugins.treesitter.enable = true;
    plugins.treesitter.settings.highlight.enable = true;
    plugins.lspconfig.enable = true;
    plugins.telescope.enable = true;
    plugins.telescope.keymaps = {
      "<leader>ff" = {
        action = "find_files";
      };
      "<leader>fg" = {
        action = "live_grep";
      };
      "<leader>fb" = {
        action = "buffers";
      };
      "<leader>fh" = {
        action = "help_tags";
      };
      "<leader>fc" = {
        action = "commands";
      };
      "<leader>fq" = {
        action = "quickfix";
      };
      "<leader>fk" = {
        action = "keymaps";
      };
      "<leader>fr" = {
        action = "lsp_references";
      };
      "<leader>fds" = {
        action = "lsp_document_symbols";
      };
      "<leader>fs" = {
        action = "lsp_workspace_symbols";
      };
      "<leader>fp" = {
        action = "diagnostics";
      };
      "<leader>fi" = {
        action = "lsp_implementations";
      };
      "<leader>fd" = {
        action = "lsp_definitions";
      };
      "<leader>ft" = {
        action = "lsp_type_definitions";
      };
      "<leader>fa" = {
        action = "builtin";
      };
      "<leader>f;" = {
        action = "resume";
      };
    };
    plugins.web-devicons.enable = true;
    plugins.lualine.enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfigVim =
    ''
      set number
      set relativenumber
      set backspace=indent,eol,start
      set hidden
      set ignorecase smartcase incsearch hlsearch
      nmap Q <Nop>
      set noerrorbells visualbell t_vb=
      highlight RedundantSpaces ctermbg=red guibg=red
      match RedundantSpaces /\s\+$/
      set viminfofile=NONE directory=/dev/shm
      set tabstop=2 softtabstop=2 shiftwidth=2 et
      set background=dark
    '';
  };

  programs.vscode = pkgs.lib.mkIf isDesktop {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      mkhl.direnv
      jnoortheen.nix-ide
    ];
    profiles.default.userSettings = {
      "editor.insertSpaces" = true;
      "editor.tabSize" = 2;
      "editor.renderWhitespace" = "boundary";
    };
  };

  services.podman = {
    enable = true;
    autoUpdate.enable = true;
    autoUpdate.onCalendar = "daily";
    containers = {
      arti = {
        image = "ghcr.io/cyberworm-uk/arti:latest";
        autoUpdate = "registry";
        autoStart = true;
        ports = [ "127.0.0.1:9050:9050" ];
        volumes = [ "arti:/arti" ];
      };
    };
    volumes.arti.autoStart = true;
  };

  fonts.fontconfig.enable = isDesktop;
  gtk.enable = isDesktop;

  stylix = if isDesktop then {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    polarity = "dark";
    image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dracula/wallpaper/refs/heads/master/first-collection/nixos.png";
        hash = "sha256-hJBs+1MYSAqxb9+ENP0AsHdUrvjTzjobGv57dx5pPGE=";
    };
    targets.firefox.profileNames = [ "default" ];
    fonts = {
      serif = {
        package = pkgs.nerd-fonts.noto;
        name = "NotoSerif NF";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.noto;
        name = "NotoSans NF";
      };
      monospace = {
        package = pkgs.nerd-fonts.noto;
        name = "NotoMono NFM";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  } else {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    polarity = "dark";
    image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dracula/wallpaper/refs/heads/master/first-collection/nixos.png";
        hash = "sha256-hJBs+1MYSAqxb9+ENP0AsHdUrvjTzjobGv57dx5pPGE=";
    };
    targets.starship.enable = true;
    targets.nushell.enable = true;
    autoEnable = false;
  };
  sops.age.sshKeyPaths = [ "/home/user/.ssh/id_ed25519" ];
  sops.secrets."spotify-client-id" = {
    sopsFile = secrets/user-secrets.yaml;
    format = "yaml";
  };
  sops.templates."spotify-client-id".content = "${config.sops.placeholder.spotify-client-id}";
}
