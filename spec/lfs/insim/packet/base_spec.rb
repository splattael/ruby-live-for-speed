require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "A" do

  describe "tiny packet" do
  
    before do
      @packet = ::LFS::Parser::Packet.create(:TINY, :subtype => :VER)
    end

    it "is 4 bytes long" do
      @packet.to_s.size.should == 4
    end

    it "match type correctly" do
      @packet.should === :TINY
      @packet.should === :TINY_VER
    end

  end

end
