{ self, pkgs, isDesktop, ... }:

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
    [ whois (lib.hiPrio uutils-coreutils-noprefix) jq p7zip ]
    ++ lib.optionals (isDesktop) [ tor-browser jellyfin-media-player];

  home.shell.enableBashIntegration = true;

  programs.home-manager.enable = true;
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
  programs.ghostty = pkgs.lib.mkIf isDesktop {
    enable = true;
    installVimSyntax = true;
    enableBashIntegration = true;
    settings = {
      theme = "Dracula";
    };
  };
  programs.firefox = pkgs.lib.mkIf isDesktop {
    enable = true;
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
        "CanvasBlocker@kkapsner.de" = {
          "installation_mode" = "force_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/canvasblocker/latest.xpi";
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
      dracula-theme.theme-dracula
    ];
  };

  nix.package = pkgs.nixVersions.latest;

  stylix = if isDesktop then {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    polarity = "dark";
    image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dracula/wallpaper/refs/heads/master/first-collection/nixos.png";
        hash = "sha256-hJBs+1MYSAqxb9+ENP0AsHdUrvjTzjobGv57dx5pPGE=";
    };
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
    autoEnable = false;
  };
}
