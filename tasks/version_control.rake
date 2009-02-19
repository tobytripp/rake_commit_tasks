require "version_control/detect"

namespace :vc do
  vc = VersionControl::Detect.detect
  
  task :up do
    puts vc.up
  end
  
  task :delete
  
  task :add
  
  task :st do
    puts vc.st
  end
  
end
