module VersionControl
  class Detect
    def self.detect
      git_dir = %x[git-rev-parse --show-cdup 2>&1]
      
      if git_dir.index( "fatal: Not a git repo" ).nil?
        Git.new
      else
        Subversion.new
      end
    end
  end
end
