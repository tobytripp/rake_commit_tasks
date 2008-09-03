module VersionControl
  class Git
    def up
      out = %x[git pull origin]

      out.each do |line|
        raise(
          "Merge conflict detected.  Please resolve conflicts before proceeding." 
        ) if line =~ /^CONFLICT/
      end
      
      out
    end
    
    def st
      %x[git diff --name-status]
    end
  end
end