class TabSwitch < Formula
  desc "Keyboard window switcher for macOS (Cmd+Tab / Option+Tab across windows)"
  homepage "https://github.com/Zappendusta/tab-switch"
  url "https://github.com/Zappendusta/tab-switch/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "54638904881e0587d1b01cd921c592701d36c6f471456cbc1b37e0883af47b36"
  license "MIT"
  head "https://github.com/Zappendusta/tab-switch.git", branch: "master"

  depends_on xcode: :build
  depends_on macos: :ventura

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin_path = Utils.safe_popen_read("swift", "build", "--disable-sandbox",
                                     "-c", "release", "--show-bin-path").strip

    app = prefix/"tab-switch.app"
    (app/"Contents/MacOS").mkpath
    cp "#{bin_path}/TabSwitchApp", app/"Contents/MacOS/tab-switch"

    (app/"Contents/Info.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleName</key><string>tab-switch</string>
        <key>CFBundleIdentifier</key><string>local.tabswitch</string>
        <key>CFBundleExecutable</key><string>tab-switch</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleShortVersionString</key><string>#{version}</string>
        <key>LSMinimumSystemVersion</key><string>13.0</string>
        <key>LSUIElement</key><true/>
      </dict>
      </plist>
    PLIST

    bin.install_symlink app/"Contents/MacOS/tab-switch" => "tab-switch"
  end

  service do
    run [opt_prefix/"tab-switch.app/Contents/MacOS/tab-switch"]
    keep_alive true
    run_at_load true
  end

  def caveats
    <<~EOS
      tab-switch needs Accessibility permission to read window state and post
      keyboard events. After installing, grant it in:
        System Settings -> Privacy & Security -> Accessibility

      Start it (and enable auto-start at login) with:
        brew services start tab-switch

      NOTE: tab-switch is built from source, so each `brew upgrade` produces a
      new binary identity. macOS will require you to re-grant Accessibility
      after every upgrade.
    EOS
  end

  test do
    assert_predicate prefix/"tab-switch.app/Contents/MacOS/tab-switch", :executable?
    assert_path_exists prefix/"tab-switch.app/Contents/Info.plist"
  end
end
