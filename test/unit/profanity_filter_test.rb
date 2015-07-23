require "test_helper"

BIG_NUMBER_OF_COMMENTS = 200

class ProfanityFilterTest < ActionController::TestCase

  tests CallToActionController

  def setup
    switch_tenant("fandom")
    load_seed("profanity_settings")

    @bad_comments = [
      "This is a profanity", 
      "You are a badword", 
      "Bad words in here", 
      "If YoU sAy PrOfAnItIeS yOu ArE iNsEnSiTiVe"
    ]

    @good_comments = [
      "Ok", 
      "No curses here", 
      "Love for all", 
      "badwordasradix is ok..."
    ]

    @special_chars_comments = [
      ";,:.ç°#§*", 
      "[]{}?\\^=()",
      "/&%$£€\"!\'|<>-_"
    ]
  end

  test "filter on special characters" do
    @special_chars_comments.each do |c|
      assert check_profanity_words_in_comment(c).nil?, "'#{c}' did not pass filter!"
    end
  end

  test "profanity detection on bad comments" do
    @bad_comments.each do |c|
      assert check_profanity_words_in_comment(c).is_a?(Integer), "'#{c}' passed filter!"
    end
  end

  test "no profanity detection on good comments" do
    @good_comments.each do |c|
      assert check_profanity_words_in_comment(c).nil?, "'#{c}' did not pass filter!"
    end
  end

  test "profanity detection on a big number of bad comments" do
    generate_and_test_comments_with_profanities(BIG_NUMBER_OF_COMMENTS)
  end

  # A little performance test
  def generate_and_test_comments_with_profanities(comments_number)
    start_time = Time.now
    puts "\nStart check for profanity for #{ comments_number } comments"

    comments_number.times do
      comment = generate_random_string()
      profanity = " profanity "
      comment.insert(rand(comment.length), profanity)
      assert check_profanity_words_in_comment(comment).is_a?(Integer), "'#{ comment }' passed filter!"
    end

    puts "Profanity check completed in #{ Time.now - start_time } seconds"
  end

  def generate_random_string(length = 64)
    chars = 'abcdefghjkmnpqrstuvwxyz àèìòù ABCDEFGHJKLMNOPQRSTUVWXYZ 123456789 ;,:.ç°#§*[]{}?\\^=()/&%$£€"!\'|<>-_'
    Array.new(length) { chars[rand(chars.length)].chr }.join
  end

end