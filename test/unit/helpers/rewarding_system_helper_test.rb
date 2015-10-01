require('test_helper')
 
class RewardingSystemHelperTest < ActiveSupport::TestCase
  
  def initialize(args)
    super(args)
    fd = open("#{File.dirname(__FILE__)}/../../etc/sample_rules.rb")
    @rules = fd.read
  end

  test "rules errors" do
    if false
      fd = open("#{File.dirname(__FILE__)}/../../etc/sample_rules_with_errors.rb")
      rules_buffer = fd.reads
      
      errors = check_rules(rules_buffer)
      expected_errors = [
        "rule OPTIONS: unrecognized option: reward", 
        "rule OPTIONS: rewards and unlocks are both missing", 
        "rule DUP: duplicated"
      ]
      errors.sort!
      expected_errors.sort!
      assert errors == expected_errors 
    end    
  end
  
end
