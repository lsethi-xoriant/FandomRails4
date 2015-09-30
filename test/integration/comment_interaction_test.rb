require "test_helper"

class CommentInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @comment_text = "Hi there!"
  end

  test "comment interaction" do

    cta_link = login_and_find_call_to_action_with_title("Chi dei musicisti dei Coldplay è il vostro preferito?")
    visit(cta_link)

    page.fill_in "text", :with => @comment_text
    page.find("button[ng-click='submitComment(interaction_info)']").click
    assert assert_selector("button[class='modal__custom__button-sign-up btn btn-primary']"), "Moderation message did not appear"

    visit(build_url_for_capybara("/easyadmin/comments/to_approved"))

    if page.has_selector?("ul[class='pagination']") # go to last page to find comment in easyadmin
      within("ul.pagination") do
        within all("li").last do
          find("a").click
        end
      end
    end

    within("tbody") do
      within all("tr").last do
        find("button[onclick^='updateComment(true']").click
      end
    end

    visit(cta_link)

    last_comment_text = all("p.comment-interaction__text-p").first.text[-(@comment_text.size)..-1]

    assert last_comment_text == @comment_text, "Comment should be \"#{@comment_text}\", but it is \"#{last_comment_text}\""

    visit(build_url_for_capybara("/easyadmin/comments/approved"))

    within("tbody") do
      within first("tr") do
        find("button[onclick^='updateComment(").click
      end
    end

    perform_logout

  end

end