ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  CORRECT_ANSWER = true
  INCORRECT_ANSWER = false

  CTA_TEST_NAME = "cta-for-user-interactions-testing"

  # Add more helper methods to be used by all tests here
  def load_seed(seed_name, path = "seeds")
    seed = open("#{File.dirname(__FILE__)}/#{path}/#{seed_name}.rb")
    eval(seed.read)
  end

  def quiz?(resource_type)
    resource_type == "Quiz"
  end

  def get_random_property
    random_property_name = $site.allowed_context_roots.sample
    Tag.find(random_property_name)
  end

  def get_default_property
    Tag.find($site.default_property)
  end

  def current_user
    @current_user.nil? ? User.find_by_email("atolomio@shado.tv") : @current_user
  end

  def initialize_tenant
    switch_tenant("fandom")
  end

  def get_counter(ref_type, ref_id)
    ViewCounter.where(ref_type: ref_type, ref_id: ref_id).first
  end

  def lorem_ipsum()
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  end

  # SEEDS HELPER

  def build_quiz_interaction(cta, quiz_type, one_shot = true)
    resource = Quiz.new(question: lorem_ipsum, quiz_type: quiz_type, one_shot: one_shot)

    answers_correctly = quiz_type == "TRIVIA" ? [CORRECT_ANSWER, INCORRECT_ANSWER] : [INCORRECT_ANSWER, INCORRECT_ANSWER]

    answers_correctly.each do |correct|
      resource.answers.build(text: lorem_ipsum, correct: correct)
    end

    resource.save
    
    build_interaction(cta, resource)
  end

  def build_base_interaction(cta, resource_type, params = {})
    resource = Object.const_get(resource_type).create(params)
    build_interaction(cta, resource)  
  end

  def build_interaction(cta, resource)
    Interaction.create(
      resource: resource, 
      when_show_interaction: "SEMPRE_VISIBILE",
      call_to_action_id: cta.id,
      registration_needed: false
    )
  end

end