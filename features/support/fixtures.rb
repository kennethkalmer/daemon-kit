module ProjectFixtures
  DAEMON_FIXTURES_PATH = File.expand_path( '../../../spec/fixtures', __FILE__ )

  def copy_fixture_project( name )
    name = case name
          when '0.2.3'
            'zero_two_three'
          else
            raise ArgumentError, "Unknown fixture project: #{name}"
          end

    src = File.join( DAEMON_FIXTURES_PATH, name )

    in_current_dir do
      FileUtils.cp_r( src, 'fixture_project' )
    end
  end

end

World( ProjectFixtures )
