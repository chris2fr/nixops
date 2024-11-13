{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; }
, buildGoModule ? pkgs.buildGoModule
, fetchFromGitHub ? pkgs.fetchFromGitHub
, installShellFiles ? pkgs.installShellFiles
, nixosTests ? pkgs.nixosTests
}:

rec {
  pname = "sftpgo-plugin-auth";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "sftpgo";
    repo = "sftpgo-plugin-auth";
    rev = "refs/tags/v${version}";
    hash = "sha256-HsSBW30qSU3SRyexk2tRjY1FQcBsa70fK3UuT+Gdtm0=";
  };

  vendorHash = "sha256-BMwEDsXzk8ExygKreWmtkNvhlg3+YU9KcY1pp+9XffI=";

  # ldflags = [
  #   "-s"
  #   "-w"
  # ];

    # "-X github.com/drakkan/sftpgo/v2/internal/version.commit=${src.rev}"
    # "-X github.com/drakkan/sftpgo/v2/internal/version.date=1970-01-01T00:00:00Z"

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false;

  subPackages = [ "." ];

    # buildPhase = ''
    #   mkdir -p $out/bin
    # '';


  postInstall = ''
    mkdir -p $out/bin
    $out/bin/sftpgo-plugin-auth gen man
    installManPage man/*.1

    installShellCompletion --cmd sftpgo-plugin-auth \
      --bash <($out/bin/sftpgo-plugin-auth gen completion bash) \
      --zsh <($out/bin/sftpgo-plugin-auth gen completion zsh) \
      --fish <($out/bin/sftpgo-plugin-auth gen completion fish)

    shareDirectory="$out/share/sftpgo-plugin-auth"
    mkdir -p "$shareDirectory"
    # cp -r ./{openapi,static,templates} "$shareDirectory"
  '';

  # passthru.tests = nixosTests.sftpgo;

  meta = with pkgs.lib; {
    homepage = "https://github.com/sftpgo/sftpgo-plugin-auth";
    changelog = "https://github.com/sftpgo/sftpgo-plugin-auth/releases/tag/v${version}";
    description = "This plugin enables LDAP/Active Directory authentication for SFTPGo.";
    longDescription = ''
      The plugin can be configured within the plugins section of the SFTPGo configuration file or (recommended) using environment variables. To start the plugin you have to use the serve subcommand.
    '';
    license = with licenses; [ agpl3Only unfreeRedistributable ]; # Software is AGPLv3, web UI is unfree
    maintainers = with maintainers; [ thenonameguy yayayayaka ];
    mainProgram = "sftpgo-plugin-auth";
  };
}