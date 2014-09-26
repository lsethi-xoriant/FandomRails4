require "aws-sdk"
require "open3"
require "colorize"
require_relative "../lib/cli_utils"
include CliUtils

AWS_REMOTE_UPDATE_COMMAND = "bash -l ~/bin/aws_remote_update.sh"

def main
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
        app_user = config['app_user']

        print "restarting application server #{app_user}@#{instance.dns_name}... "
        $stdout.flush
        
        input, output, error_output, thread = Open3::popen3("ssh -oStrictHostKeyChecking=no #{app_user}@#{instance.dns_name} \"#{AWS_REMOTE_UPDATE_COMMAND}\"")
        if thread.value.exitstatus == 0
          puts "ok.".green
        else
          puts "failed!".red
          puts "command output: " + output.read
          puts "command error output: " + error_output.read
        end
      end
    end
  end  
  
end

main()
