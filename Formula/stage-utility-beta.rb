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
  version "1.29.0-beta.19"
  conflicts_with "stage-utility", because: "both install a stage-utility binary"
  license "GPL-3.0-or-later"

  # Each archive already contains a Node runtime, so nothing is built. ffmpeg is
  # the system's own, which the Video relay's audio conversion needs.
  depends_on "ffmpeg"

  on_macos do
    on_arm do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-darwin-arm64.tar.gz"
      sha256 "4057510ef3bdae27e5385fe2c1f93fe3f6aa642562f9170205fb9adad845f669"
    end
    on_intel do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-darwin-x64.tar.gz"
      sha256 "6bf9e3b1f1a9a1f827dca7755a0b6535c0249e756f2d1fa16420a0aa510ce0d5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-linux-arm64.tar.gz"
      sha256 "d409aeba341b7d03dae9097456a92b32b8da120a98707553bdbad68b35c1ca25"
    end
    on_intel do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-linux-x64.tar.gz"
      sha256 "0f02ca5e1456fdc86b865c9ac7c5cd7cb633b025e7240ccb20c64ce1af065b5d"
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
