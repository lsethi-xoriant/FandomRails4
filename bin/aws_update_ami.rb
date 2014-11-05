require "aws-sdk"
require_relative "../lib/cli_utils"
include CliUtils

SLEEP_COUNT = 300

# Returns an hash with the script configuration
def get_config()
  config = get_deploy_settings
  AWS.config(
    :access_key_id => config['aws']['access_key_id'],
    :secret_access_key => config['aws']['secret_access_key'])
  config['aws']
end

# Gets an aws element (ami, group, etc.) id by name
def get_element_id_by_name(field_name, name, ec2, &block)
  # using memoize only 1 call to aws will be done
  AWS.memoize do
    elements = (yield block)
      .filter(field_name, name)
    if elements.count == 0
      puts "Element #{name} not found!"
      exit 1
    end
    elements.first.id
  end  
end

def get_ami_id(ami_name, ec2)
  get_element_id_by_name("name", ami_name, ec2) { ec2.images.with_owner(:self) }
end

def get_security_group_id(security_group_name, ec2)
  get_element_id_by_name("group-name", security_group_name, ec2) { ec2.security_groups }
end


# Wait (by polling) that a group reaches the desired instance capacity
def wait_on_desired_capacity(group, desired_capacity)
  while true
    current_instance_count = 0
    running_instance_count = 0
    AWS.memoize do
      group.ec2_instances.each do |instance|
        if instance.status != :terminated
          current_instance_count += 1
        end
        if instance.status == :running
          running_instance_count += 1
        end
      end
    end
    if running_instance_count == desired_capacity
      puts "the desired capacity has been reached"
      break
    else
      puts "running/current/desired instances: #{running_instance_count}/#{current_instance_count}/#{desired_capacity}"
      sleep 10
    end
  end
end

def create_launch_configuration(auto_scaling, ec2, postfix, config)
  ami_name = config['ami_prefix'] + postfix
  ami_id = get_ami_id(ami_name, ec2)
  
  launch_configuration_name = config["launch_configuration_prefix"] + postfix
  unless auto_scaling.launch_configurations[launch_configuration_name].exists?
    security_group_id = get_security_group_id(config["appserver_security_group"], ec2)
    auto_scaling.launch_configurations.create(
      launch_configuration_name, 
      ami_id,
      config["instance_type"], 
      :security_groups => ["sg-c64d8aa3"],
      :key_pair => config["key_pair"],
      :user_data => config.fetch('launch_configuration_user_data', '')
      )
  end
  return launch_configuration_name
end

def main
  if ARGV.size < 1
    puts "\
Usage: #{$0} <postfix>\n\
  Create a new launch configuration with a new AMI.\n\
  'postfix' is the postfix used to name the AMI and the launch configuration (tipically a timestamp)\n\
"
    exit
  end
  
  postfix = ARGV[0]
  
  config = get_config()  
  
  ec2 = AWS::EC2.new(:region => config['region'])  
  auto_scaling = AWS::AutoScaling.new(:region => config['region'])

  launch_configuration_name = create_launch_configuration(auto_scaling, ec2, postfix, config)  

  group = auto_scaling.groups[config["autoscaling_group"]]
  instance_count = group.ec2_instances.count
  max_size = group.max_size 
  if instance_count > max_size
    instance_count = max_size
  end

  puts "updating group:\n\
  launch configuration: #{launch_configuration_name}\n\
  desired capacity: #{instance_count * 2}\n\
  max_size: #{max_size * 2}\n\
"
  
  group.update(
    :launch_configuration => launch_configuration_name,
    :desired_capacity => instance_count * 2,
    :max_size => max_size * 2
  )
  
  wait_on_desired_capacity(group, instance_count * 2)

  puts "waiting on instances to finish their bootstrap: #{SLEEP_COUNT}s. Countdown:"
  SLEEP_COUNT.times do |i|
    print(i % 5 == 0? "#{i}" : '.')
    $stdout.flush
    sleep(1)
  end
  puts 'done.'

  puts "restoring original group capacity:\n\
  desired capacity: #{instance_count}\n\
  max_size: #{max_size}\n\
"
  group.update(
    :desired_capacity => instance_count,
    :max_size => max_size
  )

  wait_on_desired_capacity(group, instance_count)

end

main()
