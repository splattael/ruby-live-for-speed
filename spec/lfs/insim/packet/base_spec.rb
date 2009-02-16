require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "A" do

  describe "base packet" do

    describe "when defining a type" do

      before(:each) do
        LFS::Parser::Packet.define_packet :TEST, 4 do
          byte :ok
          byte spare
          word spare
        end
        @packet = ::LFS::Parser::Packet.create(:TEST)
      end

      it "has 2 spares" do
        @packet.snapshot.keys.select {|k| k =~ /^_sp/ }.size.should == 2
      end

    end

  end

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
