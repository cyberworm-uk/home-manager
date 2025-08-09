{
  description = "Home Manager configuration of user";

  inputs = {
    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.2505.*";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2505.*";
    stylix.url = "github:nix-community/stylix/release-25.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "https://flakehub.com/f/Mic92/sops-nix/*";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { ... }@inputs:
    let
      pkgsForSystem = system: import inputs.nixpkgs {
        inherit system;
      };
      mkHomeConfiguration = args: system:
        inputs.home-manager.lib.homeManagerConfiguration (rec {
          pkgs = pkgsForSystem system;
          modules = [
            ./home.nix
            inputs.stylix.homeModules.stylix
            inputs.nixvim.homeModules.nixvim
            inputs.sops-nix.homeManagerModules.sops
          ];
        } // args);
    in
    {
      homeConfigurations.desktop = mkHomeConfiguration {
        extraSpecialArgs = {
          isDesktop = true;
          inherit inputs;
        };
      } "x86_64-linux";
      homeConfigurations.laptop = mkHomeConfiguration {
        extraSpecialArgs = {
          isDesktop = true;
          inherit inputs;
        };
      } "x86_64-linux";
      homeConfigurations.terminal = mkHomeConfiguration {
        extraSpecialArgs = {
          isDesktop = false;
          inherit inputs;
        };
      } "x86_64-linux";
      homeConfigurations.rpi = mkHomeConfiguration {
        extraSpecialArgs = {
          isDesktop = false;
          inherit inputs;
        };
      } "aarch64-linux";
    };
}
