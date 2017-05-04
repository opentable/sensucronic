require "sensucronic/version"
require 'mixlib/cli'

class Sensuchronic
  include Mixlib::CLI

  option :dryrun,
    :default => false,
    :boolean => true,
    :short   => '-d',
    :long    => '--dry-run'

  def run
    parse_options
    puts cli_arguments.join(" ")
    puts "tada #{config[:foo]}"
  end

end
