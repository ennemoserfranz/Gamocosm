require 'test_helper'

class MCSWTest < ActiveSupport::TestCase

  def setup
    @minecraft = Minecraft.first
  end

  test 'http timeout' do
    mock_do_base(200)
    mock_do_droplet_show(1).stub_do_droplet_show(200, 'active').times_only(1)
    mock_mcsw_pid(@minecraft).to_timeout.times_only(1)
    mock_mcsw_start(@minecraft).to_timeout.times_only(1)
    begin
      @minecraft.server.update_columns(remote_id: 1)
      res = @minecraft.node.pid
      assert res.error?, 'Response should be an error'
      assert_equal 'MCSW API network exception: execution expired', res, 'Response should be about a network exception'
      res = @minecraft.node.resume
      assert res.error?, 'Response should be an error'
      assert_equal 'MCSW API network exception: execution expired', res, 'Response should be about a network exception'
    ensure
      @minecraft.server.update_columns(remote_id: nil)
    end
  end

  test 'properties' do
    mock_do_droplet_show(1).stub_do_droplet_show(200, 'active').times_only(1)
    mock_mcsw_properties_fetch(@minecraft).stub_mcsw_properties_fetch(400, {}).times_only(1)
    begin
      @minecraft.server.update_columns(remote_id: 1)
      p = @minecraft.properties
      p.refresh
      assert p.error?
      assert_match /MCSW API error: HTTP response code 400/, p.error
    ensure
      @minecraft.server.update_columns(remote_id: nil)
    end
  end
end
