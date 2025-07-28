{
  description = "Home Manager configuration of user";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";
    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.2505.*";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2505.*";
    stylix.url = "github:nix-community/stylix/release-25.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "https://flakehub.com/f/Mic92/sops-nix/*";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, ... }@inputs:
    let
      pkgsForSystem = system: import inputs.nixpkgs {
        inherit system;
      };
      mkHomeConfiguration = args: inputs.home-manager.lib.homeManagerConfiguration (rec {
        pkgs = pkgsForSystem args.system or "x86_64-linux";
        modules = [
          ./home.nix
          inputs.stylix.homeModules.stylix
          inputs.nixvim.homeModules.nixvim
        ];
      } // args);
    in
    {
      homeConfigurations.desktop = mkHomeConfiguration {
        extraSpecialArgs = {
          isDesktop = true;
        };
      };
      homeConfigurations.rpi = mkHomeConfiguration {
        system = "aarch64-linux";
        extraSpecialArgs = {
          isDesktop = false;
        };
      };
      homeConfigurations.penguin = mkHomeConfiguration {
        extraSpecialArgs = {
          isDesktop = true;
        };
      };
    };
}
