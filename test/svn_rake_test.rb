require File.dirname(__FILE__) + "/test_helper"

class SvnRakeTest < Test::Unit::TestCase
  
  test "svn:st displays svn status" do
    stub_shell "svn st"
    assert_equal "output from svn st\n", execute_task( "svn:st" )
  end
  
  test "svn:up displays output from svn" do
    stub_shell "svn up"
    assert_equal "output from svn up\n", execute_task( "svn:up" )
  end
  
  test "svn:up raises if there are conflicts" do
    stub_shell "svn up", "C      a_conflicted_file\n"
    begin
      execute_task "svn:up"
    rescue => exception
    end
    
    assert_not_nil exception
    assert_equal "SVN conflict detected. Please resolve conflicts before proceeding.", exception.message
  end
  
  test "svn:add adds new files and displays message" do
    stub_shell "svn st", "?      new_file\nM      modified_file\n?      new_file2\n"
    stub_shell "svn add \"new_file\""
    stub_shell "svn add \"new_file2\""
    
    assert_equal "added new_file\nadded new_file2\n", execute_task( "svn:add" )
  end

  test "svn:add adds files with special characters in them" do
    stub_shell "svn st", "?       leading_space\n?      x\"x\n?      y?y\n?      z'z\n"
    vc.expects(:`).with(%Q(svn add " leading_space"))
    vc.expects(:`).with(%Q(svn add "x\\\"x"))
    vc.expects(:`).with(%Q(svn add "y?y"))
    vc.expects(:`).with(%Q(svn add "z'z"))
    
    execute_task "svn:add"
  end
  
  test "svn:add does not add svn conflict files" do
    vc.expects(:`).never
    stub_shell "svn st", "?      new_file.r342\n?      new_file.mine"
    
    assert_equal "\n", execute_task( "svn:add" )
  end
  
  test "svn:rm is an alias for svn:delete" do
    assert_equal ["svn:delete"], Rake::Task["svn:rm"].prerequisites
  end

  test "svn:delete removes deleted files and displays message" do
    vc.stubs(:`).with("svn st").returns("!      removed_file\n?      new_file\n!      removed_file2\n")
    vc.expects(:`).with("svn up \"removed_file\" && svn rm \"removed_file\"")
    vc.expects(:`).with("svn up \"removed_file2\" && svn rm \"removed_file2\"")
    
    assert_equal "removed removed_file\nremoved removed_file2\n", execute_task( "svn:delete" )
  end
  
  test "svn:revert_all calls svn revert and then removes all new files and directories" do
    vc.expects(:system).with('svn revert -R .')
    vc.expects(:`).with("svn st").returns("?    some_file.rb\n?    a directory")
    vc.expects(:rm_r).with("some_file.rb")
    vc.expects(:rm_r).with("a directory")
    
    execute_task( "svn:revert_all" )
  end

  protected

  def vc
    VersionControl::Subversion.any_instance
  end

  def stub_shell command, result="output from #{command}"
    VersionControl::Subversion.any_instance.stubs( :` ).with( command ).returns result
  end

  def execute_task task_name
    capture_stdout do
      Rake::Task[ task_name ].execute nil
    end
  end
  
end
