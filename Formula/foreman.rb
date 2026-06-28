class Foreman < Formula
  desc "A Claude Code framework for structured, verified AI-assisted development"
  homepage "https://github.com/michaelvgonzaga/foreman"
  head "https://github.com/michaelvgonzaga/foreman.git", branch: "main"

  depends_on "git"

  def install
    prefix.install Dir["*", ".*"]

    (bin/"foreman").write <<~EOS
      #!/bin/bash
      set -e

      # Check Claude Code
      if ! command -v claude &>/dev/null; then
        echo ""
        echo "  ERROR: Claude Code is not installed."
        echo ""
        echo "  Install it first:"
        echo "    https://claude.ai/code"
        echo ""
        exit 1
      fi

      # Check Git
      if ! command -v git &>/dev/null; then
        echo ""
        echo "  ERROR: Git is not installed."
        echo ""
        echo "  Install it with:"
        echo "    brew install git"
        echo ""
        exit 1
      fi

      exec claude "#{prefix}"
    EOS

    chmod 0755, bin/"foreman"
  end

  def caveats
    missing = []
    missing << "  - Claude Code   →  https://claude.ai/code" unless system("command -v claude &>/dev/null")
    missing << "  - Git           →  brew install git"       unless system("command -v git &>/dev/null")

    msg = ""
    unless missing.empty?
      msg += <<~EOS

        ⚠️  Missing prerequisites:
        #{missing.join("\n")}

      EOS
    end

    msg + <<~EOS

      To open Foreman:
        foreman

      First-time setup (inside Claude Code):
        /setup        — install plugins
        /new-project  — start your first project

    EOS
  end

  test do
    assert_predicate prefix/"README.md", :exist?
    assert_predicate bin/"foreman", :executable?
  end
end
