module Helpers
  def in_browser(name)
    old_session = ::Capybara.session_name
    ::Capybara.session_name = name
    yield
    ::Capybara.session_name = old_session
  end

  def visit_my_page
    visit "/matches/#{@match.id}/users/0"
  end
end
