# Homebrew formula for Stage Utility.
#
# Lives here so it is versioned with the code it installs, and is copied into the
# tap repository by .github/workflows/release.yml on every release. Editing it by
# hand in the tap will be overwritten — change it here.
#
#   brew tap Cornerstone-Production/stage-utility
#   brew install stage-utility
#   brew services start stage-utility
class StageUtility < Formula
  desc "Stage monitors driven by Planning Center and the gear you already run"
  homepage "https://github.com/Cornerstone-Production/Stage-Utility"
  version "1.15.0"
  license "GPL-3.0-or-later"

  # Each archive already contains a Node runtime, so the formula depends on
  # nothing and builds nothing.
  on_macos do
    on_arm do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-darwin-arm64.tar.gz"
      sha256 "c71721bb26ca55dddf56259f1473261f97036b2961a8b49873ccdcc30b77cd35"
    end
    on_intel do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-darwin-x64.tar.gz"
      sha256 "84de6b692885b9fab90c8df25d1ee5122029e1b3f2723d4a7dd5a65718b2e03c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-linux-arm64.tar.gz"
      sha256 "b55885e5f5d1cb89dce4b39c7a3c7ea961a92f0fc06f3e637bee68e79d56c484"
    end
    on_intel do
      url "https://github.com/Cornerstone-Production/Stage-Utility/releases/download/v#{version}/stage-utility-#{version}-linux-x64.tar.gz"
      sha256 "5327cc5630c8319c83832bb1efb1889e0784417f986241cb65f0e924c784ce09"
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
