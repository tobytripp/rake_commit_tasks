require "version_control/git"
vc = VersionControl::Git.new

namespace :git do
  desc "display git status"
  task :st do
    puts vc.st
  end
  
  desc "Update from remote origin"
  task :up do
    puts vc.up
  end
end
