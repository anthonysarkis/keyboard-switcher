enum Usage {
    static let text = """
    Usage: keyboard-switcher-dev <command>
      keyboards           List the keyboards turned on in macOS.
      switch-test         Switch to another keyboard and straight back, to check switching works.
      languages           Print every keyboard language macOS ships, as a Markdown table with flags.
      badges              Check that macOS draws the badges, and how close the app's own drawing comes.
      snapshots <folder>  Draw the Settings tabs, the badges and the bubbles as PNG files.
      readme-images       Draw the README pictures into docs/images: the animated SVGs and the Settings tabs.
    """
}
