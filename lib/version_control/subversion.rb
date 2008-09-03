module VersionControl
  class Subversion
    def st
      %x[svn st]
    end

    def up
      output = %x[svn up]

      if output.detect { |line| line[0,1] == "C" }
        raise "SVN conflict detected. Please resolve conflicts before proceeding."
      end
      
      output
    end

    def add
      %x[svn st].split("\n").map { |line|
        if new_file?(line) && !svn_conflict_file?(line)
          file = line[7..-1]
          %x[svn add #{file.inspect}]
          %[added #{file}]
        end
      }.compact
    end

    def new_file?(line)
      line[0,1] == "?"
    end

    def svn_conflict_file?(line)
      line =~ /\.r\d+$/ || line =~ /\.mine$/
    end

    def delete
      %x[svn st].split("\n").map { |line|
        if line[0,1] == "!"
          file = line[7..-1]
          %x[svn up #{file.inspect} && svn rm #{file.inspect}]
          %[removed #{file}]
        end
      }.compact
    end

    def revert_all
      system "svn revert -R ."
      %x[svn st].split("\n").each do |line|
        next unless line[0,1] == '?'
        filename = line[1..-1].strip
        rm_r filename
        "removed #{filename}"
      end
    end
    
  end
end