require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

require 'lfs/session'

describe "Relay" do

  describe "asking for hostlist" do

    before(:all) do
      @hostlist = LFS::RelayedSession.hostlist
    end

    it "should not be empty" do
      @hostlist.should_not be_empty
    end

    it "should have host info" do
      host_info = @hostlist[0]
      host_info.should_not be_nil
      host_info.hostname.should_not be_nil
      host_info.track.should_not be_nil
      host_info.flags.should_not be_nil
      host_info.connections.should > 0
    end

  end

end
