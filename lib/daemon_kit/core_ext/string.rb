require 'pathname'

class String

  # Assuming the string is a file or path name, convert it into an
  # absolute path.
  def to_absolute_path
    # Pathname is incompatible with Windows, but Windows doesn't have
    # real symlinks so File.expand_path is safe.
    if RUBY_PLATFORM =~ /(:?mswin|mingw)/
      File.expand_path( self )

      # Otherwise use Pathname#realpath which respects symlinks.
    else
      begin
        File.expand_path( Pathname.new( self ).realpath.to_s )
      rescue Errno::ENOENT
        File.expand_path( Pathname.new( self ).cleanpath.to_s )
      end
    end
  end
end
