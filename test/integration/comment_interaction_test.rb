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
    page.first("button[ng-click='submitComment(interaction_info)']").click
    assert assert_selector("button[class='modal__custom__button-sign-up btn btn-primary']"), "Moderation message did not appear"

    visit(build_url_for_capybara("/easyadmin/comments/to_approved"))

    if page.first("ul[class='pagination']") # go to last page to find comment in easyadmin
      within("ul.pagination") do
        within all("li").last do
          first("a").click
        end
      end
    end

    table_body = page.find("tbody", match: :first)

    within(table_body) do
      within all("tr").last do
        first("button[onclick^='updateComment(true']").click
      end
    end

    visit(cta_link)

    last_comment_text = all("p.comment-interaction__text-p").first.text[-(@comment_text.size)..-1]

    assert last_comment_text == @comment_text, "Comment should be \"#{@comment_text}\", but it is \"#{last_comment_text}\""

    visit(build_url_for_capybara("/easyadmin/comments/approved"))

    table_body = page.find("tbody", match: :first)

    within(table_body) do
      within first("tr") do
        first("button[onclick^='updateComment(").click
      end
    end

    perform_logout

  end

end