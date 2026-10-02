class Swiftvectorkit < Formula
  desc "Apple Silicon Native Code Intelligence & Vectorizer for Swift"
  homepage "https://github.com/alexpospekhov/SwiftVectorKit"
  url "https://github.com/alexpospekhov/SwiftVectorKit/releases/download/v0.1.0/swiftvectorkit-macos-arm64.tar.gz"
  sha256 "964a18af998b374d1a299705175de551bbdd8ffca378f87757ee152a8d0c8510"
  version "0.1.0"
  license "Apache-2.0"

  depends_on :macos
  depends_on arch: :arm64

  def install
    bin.install "swiftvectorkit"
    bin.install "swiftvector"
  end

  test do
    assert_match "SwiftVectorKit System & Hardware Status", shell_output("#{bin}/swiftvectorkit status")
  end
end
