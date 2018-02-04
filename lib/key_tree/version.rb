require 'git-version-bump'

module KeyTree
  VERSION = GVB.version.freeze
  DATE = GVB.date.freeze
end
