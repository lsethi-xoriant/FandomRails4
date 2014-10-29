require "aws-sdk"
require "open3"
require "colorize"
require_relative "../lib/cli_utils"
include CliUtils

def main
  if ARGV.size < 2
    puts <<-EOF
Usage: #{$0} <user> <command>
  Execute a shell command on every machine of an autoscaling group.
EOF
    exit
  end

  user = ARGV[0]
  command = ARGV[1]

  config = get_deploy_settings['aws']
  
  AWS.config(
    :access_key_id => config['access_key_id'],
    :secret_access_key => config['secret_access_key'])

  ec2 = AWS::EC2.new(:region => config['region'])  
  auto_scaling = AWS::AutoScaling.new(:region => config['region'])
  group = auto_scaling.groups[config['autoscaling_group']]
    
  AWS.memoize do
    group.ec2_instances.each do |instance|
      if instance.status == :running
        print "executing the command on #{user}@#{instance.dns_name}... "
        $stdout.flush
        
        input, output, error_output, thread = Open3::popen3("ssh -t -oStrictHostKeyChecking=no #{user}@#{instance.dns_name} \"#{command}\"")
        if thread.value.exitstatus == 0
          puts "ok.".green
        else
          puts "failed!".red
        end
        output_buf = output.read
        error_output_buf = error_output.read
        unless output_buf.empty?
          puts "command output:\n".yellow + output_buf
        end
        unless error_output_buf.empty?
          puts "command error output:\n".red + error_output_buf
        end
      end
    end
  end  
  
end

main()