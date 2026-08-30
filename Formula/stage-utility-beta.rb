# Homebrew formula for Stage Utility.
#
# Lives here so it is versioned with the code it installs, and is copied into the
# tap repository by .github/workflows/release.yml on every release. Editing it by
# hand in the tap will be overwritten — change it here.
#
#   brew tap Cornerstone-Production/stage-utility
#   brew install stage-utility
#   brew services start stage-utility
class StageUtilityBeta < Formula
  # Generated from stage-utility.rb - do not edit by hand.
  desc "Stage monitors driven by Planning Center and the gear you already run"
  homepage "https://github.com/Cornerstone-Production/Stage-Utility"
  version "1.13.0-beta.13"
  conflicts_with "stage-utility", because: "both install a stage-utility binary"
  license "GPL-3.0-or-later"

  # Each archive already contains a Node runtime, so the formula depends on
  # nothing and builds nothing.
  on_macos do
    on_arm do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-darwin-arm64.tar.gz"
      sha256 "9dfa833337cc732cdbb41ca801a9a4947cab4e6b3bb329aa4da8625eb17acdf5"
    end
    on_intel do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-darwin-x64.tar.gz"
      sha256 "dab68ceb2d8ea73b7b10db83313e805c0067c11d0e9f5c23b7d0beeb50bf8f41"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-linux-arm64.tar.gz"
      sha256 "bdb3907784c0addba7bf749b9267f755014497ca10afce3067a81b95132d431f"
    end
    on_intel do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-linux-x64.tar.gz"
      sha256 "a30726cf77e5c4289f44a46490ce32ad4b6c89d1b6ed290093fd08ad9f08b936"
    end
  end

  def install
    libexec.install Dir["*"]
    # A launcher rather than a symlink, so the server is always started with its
    # own bundled runtime and with the data directory pointing outside the keg —
    # `brew upgrade` replaces the keg, and configuration must survive that.
    (bin/"stage-utility").write <<~SH
      #!/bin/bash
      export STAGE_UTILITY_DATA="${STAGE_UTILITY_DATA:-#{var}/stage-utility}"
      export STAGE_UTILITY_ROOT="#{libexec}"
      exec "#{libexec}/node" "#{libexec}/server.mjs" "$@"
    SH
    chmod 0755, bin/"stage-utility"
  end

  def post_install
    (var/"stage-utility").mkpath
  end

  service do
    run [opt_bin/"stage-utility"]
    keep_alive true
    working_dir opt_libexec
    log_path var/"log/stage-utility.log"
    error_log_path var/"log/stage-utility.log"
  end

  test do
    # The bundled runtime must actually execute on this machine, and the server
    # must be the real one rather than a truncated download.
    assert_match "v24", shell_output("#{libexec}/node -v")
    assert_predicate libexec/"server.mjs", :exist?
    assert_match version.to_s, (libexec/"VERSION").read
  end
end
