require File.dirname(__FILE__) + "/test_helper"
require "version_control/detect"

module VersionControl
  def Detect.`( command )
    raise "need to stub: Detect.`(#{command.inspect})"
  end
end

class VersionControlDetectTest < Test::Unit::TestCase
  
  test "should return a Git instance if in a git repo" do
    stub_shell "git-rev-parse --show-cdup 2>&1", ""
    assert_kind_of VersionControl::Git, VersionControl::Detect.detect
  end
  
  test "should return a Subversion instance if in a svn repo" do
    stub_shell "git-rev-parse --show-cdup 2>&1", "fatal: Not a git repository"
    File.stubs( :exists? ).with( ".svn" ).returns true
    
    assert_kind_of VersionControl::Subversion, VersionControl::Detect.detect
  end
  
  protected
  
  def stub_shell command, result="output from #{command}"
    VersionControl::Detect.stubs( :` ).with( command ).returns result
  end
end
