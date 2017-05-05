require 'sensucronic/version'
require 'mixlib/cli'
require 'shellwords'
require 'open3'
require 'json'


class Sensucronic
  include Mixlib::CLI

  option :dryrun,
    :short       => '-d',
    :long        => '--dry-run',
    :boolean     => true,
    :default     => false,
    :description => 'output result to stdout only'

  option :port,
    :short       => '-p PORT',
    :long        => '--port PORT',
    :default     => 3030,
    :description => 'the port number for the sensu client input socket'

  option :source,
    :short       => '-s SOURCE',
    :long        => '--source SOURCE',
    :description => 'set the source attribute on the sensu result'

  option :help,
    :short        => '-h',
    :long         => '--help',
    :boolean      => true,
    :tail         => true,
    :show_options => true,
    :description  => 'print this message'

  attr :stdout
  attr :stderr
  attr :status

  def dryrun
    config[:dryrun]
  end

  def port
    config[:port]
  end

  def cli(argv = ARGV)
    parse_options(argv)
    run
    issue_report
  end

  def issue_report
    if dryrun
      report_stdout
    else
      report_socket
    end
  end

  def report_stdout
    puts JSON.pretty_generate(report)
  end

  def file_socket
    "/dev/tcp/localhost/#{port}"
  end

  def report_socket
    # TODO if needed actually connect via tcp to the
    # client input socket.
    File.open(file_socket, 'w') do |sock|
      sock.write(report.to_json)
    end
  rescue Errno::ENOENT => e
    STDERR.puts "failed to submit to sensu client input socket"
    STDERR.puts e.message
    exit 127
  end

  def run
    @stdout, @stderr, @status = Open3.capture3(*cli_arguments)
  rescue Errno::ENOENT => e
    @stdout, @stderr, @status = e.class, e.message, $?
  end

  def output_status
    status.to_s unless status.exited?
  end

  def output
    [stdout, stderr, output_status]
      .select {|msg| msg && msg != "" }
      .join("\n");
  end

  def exitsignal
    status.termsig || status.stopsig # I think stop sig will hang?
  end

  def exitcode
    # be like the bash on signals
    status.exited? ? status.exitstatus : 128 + exitsignal
  end

  def sensu_status
    case exitcode
    when 0..2
      exitcode
    else
      3
    end
  end

  def report
    {
      command:  Shellwords.shelljoin(cli_arguments),
      output:   output,
      status:   sensu_status,
      exitcode: exitcode,
      agent:    self.class.to_s.downcase
    }.tap do |r|
      r[:exitsignal] = status.termsig  if status.termsig
      r[:source]     = config[:source] if config[:source]
    end
  end

end
