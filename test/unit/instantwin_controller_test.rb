require "test_helper"

class InstantwinControllerTest < ActionController::TestCase

  include Devise::TestHelpers
  include InstantwinHelper

  setup do
    switch_tenant("fandom")
    load_seed("default_seed")
    @call_to_action, @interaction, @player = load_seed("instantwin")
  end

  test "has tickets and user already won" do

    assert has_tickets(), "User has no tickets"
    assert !user_already_won(@interaction.id)[:win], "User has already won"

  end

  test "winning" do

    dates_and_wins_array = generate_dates_and_wins_array(Time.parse("2015-01-01T09:00:00 +0000"), Time.parse("2015-01-01T09:59:59 +0000"), false)
    check_win_test(dates_and_wins_array)

    dates_and_wins_array = generate_dates_and_wins_array(Time.parse("2015-01-01T10:00:00 +0000"), Time.parse("2015-01-01T10:10:00 +0000"), true)
    check_win_test(dates_and_wins_array)

    dates_and_wins_array = generate_dates_and_wins_array(Time.parse("2015-01-01T10:10:01 +0000"), Time.parse("2015-01-01T10:29:59 +0000"), false)
    check_win_test(dates_and_wins_array)

    dates_and_wins_array = generate_dates_and_wins_array(Time.parse("2015-01-01T10:30:00 +0000"), Time.parse("2015-01-01T10:34:59 +0000"), true)
    check_win_test(dates_and_wins_array)

    dates_and_wins_array = generate_dates_and_wins_array(Time.parse("2015-01-01T10:35:01 +0000"), Time.parse("2015-01-01T10:44:59 +0000"), true)
    check_win_test(dates_and_wins_array)

  end

  def generate_dates_and_wins_array(from = 0.0, to = Time.now, with_a_winner = true, number_of_dates = 20)
    dates = []
    res = []
    number_of_dates.times do
      dates << (Time.at(from + rand * (to.to_f - from.to_f))) # generate a random date
    end
    if with_a_winner
      dates.sort!
      dates.each_with_index do |date, i|
        i == 0 ? res << [date, true] : [date, false]
      end
    else
      dates.each do |date|
        res << [date, false]
      end
    end
    res
  end

  def check_win_test(dates_and_wins_array)
    dates_and_wins_array.each do |date_and_win|
      date = date_and_win[0]
      win = date_and_win[1]
      travel_to date do
        instantwin, prize = check_win(@interaction, Time.now.utc)

        assert instantwin.present? == win, "check_win method for #{date} play gave instantwin.present? = #{instantwin.present?}"
        assert prize.present? == win, "check_win method for #{date} play gave prize.present? = #{instantwin.present?}"
        if instantwin
          assert instantwin.won == win, "instantwin.won for #{date} play is #{instantwin.won}"
        end
      end
    end
  end

  def get_instantwin_ticket_name()
    "instantwin-currency"
  end

  def current_user
    @player
  end

end