require File.join( File.dirname(__FILE__), "test_helper" )

class GitRakeTest < Test::Unit::TestCase
  
  test "git:st displays git name status" do
    stub_shell "git diff --name-status"
    assert_equal "output from git diff --name-status\n", execute_task( "git:st" )
  end
  
  test "git:up displays output from git pull" do
    stub_shell "git pull origin"
    assert_equal "output from git pull origin\n", execute_task( "git:up" )
  end

  test "git:up raises on conflict" do
    stub_shell "git pull origin", "CONFLICT (content): Merge conflict in a file\n"
    begin
      execute_task "git:up"
    rescue => exception
    end
    
    assert_not_nil exception
    assert_equal "Merge conflict detected.  Please resolve conflicts before proceeding.",
      exception.message
  end
  
  protected

  def stub_shell command, result="output from #{command}"
    VersionControl::Git.any_instance.stubs( :` ).with( command ).returns result
  end
  
  def execute_task task_name
    capture_stdout do
      Rake::Task[ task_name ].execute nil
    end
  end
end