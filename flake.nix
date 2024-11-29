{
  description = "disko fail case";

  inputs = {
    disko.url = "github:nix-community/disko/bba79f6b5eea35713f27815acbcda8775025e4c3";
    #disko.url = "github:RadxaYuntian/disko/7282c989c39ddbd7c6af08d25be7dc850e40ed5c";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = inputs@{ self, disko, nixpkgs }: {
    nixosConfigurations.test = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        disko.nixosModules.disko
        ({ config, ... }: {
          disko = {
            imageBuilder = {
              qemu = nixpkgs.legacyPackages.x86_64-linux.qemu + "/bin/qemu-system-aarch64 -M virt -cpu cortex-a57";
            };
            devices = {
              disk = {
                main = {
                  device = "/dev/disk/by-id/TARGET-DEVICE";
                  type = "disk";
                  imageSize = "10G";
                  content = {
                    type = "gpt";
                    partitions = {
                      ESP = {
                        type = "EF00";
                        size = "500M";
                        content = {
                          type = "filesystem";
                          format = "vfat";
                          mountpoint = "/boot";
                        };
                      };
                      root = {
                        size = "100%";
                        content = {
                          type = "filesystem";
                          format = "btrfs";
                          mountpoint = "/";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
          system.stateVersion = config.system.nixos.version;
        })
      ];
    };
  };
}

# nix build .#nixosConfigurations.test.config.system.build.diskoImagesScript
