require './test/test_helper'

module TrafficSpy

  class ApplicationDetailsTest < Minitest::Test

    def test_the_page_has_a_title
      visit "/sources/jumpstartlab"

      assert page.has_content?("Application Details")
    end
  end
end