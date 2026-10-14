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
  version "1.26.0-beta.11"
  conflicts_with "stage-utility", because: "both install a stage-utility binary"
  license "GPL-3.0-or-later"

  # Each archive already contains a Node runtime, so the formula depends on
  # nothing and builds nothing.
  on_macos do
    on_arm do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-darwin-arm64.tar.gz"
      sha256 "b343ea66a561fd6586e6919715a56c7b6748e62136975115ff666fc4ba085285"
    end
    on_intel do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-darwin-x64.tar.gz"
      sha256 "0cd7a9472712882199b22f79933d7d3894601d20ac755bc955c882b7649719fb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-linux-arm64.tar.gz"
      sha256 "e2b9143f6d82a9d13a61803ec256be442f9a4a245e081fd3bc70a1ec4d823a77"
    end
    on_intel do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-linux-x64.tar.gz"
      sha256 "71e566b4e17b60e18c2e4eb561529e4aa391f4670ef679323cea6e510060ee55"
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
