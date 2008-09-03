require "version_control/subversion"
vc = VersionControl::Subversion.new

namespace :svn do
  desc "display svn status"
  task :st do
    puts vc.st
  end

  desc "svn up and check for conflicts"
  task :up do
    puts vc.up
  end

  desc "add new files to svn"
  task :add do
    puts vc.add.join("\n")
  end
  
  desc "remove deleted files from svn"
  task :delete do
    puts vc.delete
  end
  task :rm => "svn:delete"
  
  desc "reverts all files in svn and deletes new files"
  task :revert_all do
    puts vc.revert_all
  end

end
