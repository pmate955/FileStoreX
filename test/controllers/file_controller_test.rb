require 'test_helper'

class FileControllerTest < ActionDispatch::IntegrationTest
  test "should get upload" do
    get file_upload_url
    assert_response :success
  end

end
