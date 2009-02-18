require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "A" do

  describe "base packet" do

    describe "checking size" do

      before do
        @io = StringIO.new
      end

      LFS::Parser::Packet.each_packet_class do |key, packet_class|
        if size = packet_class.packet_size
          it "have correct static packet sizes for #{packet_class.name}" do
            packet = packet_class.create
            packet.write(@io)
            @io.size.should == packet.packet_size
            @io.size.should == size
          end
        else
          p packet_class.name
        end
      end

      it "has correct dynamic size for BTN"

      it "has correct dynamic size for HOS"

      it "has correct dynamic size for UNKN"

      it "has correct dynamic size for MCI"
      
      it "has correct dynamic size for NLP" do
        packet = :NLP.to_packet
        packet.nodes.push(*([ LFS::Parser::Types::NodeLap.new ] * 8))
        packet.players = packet.nodes.size
        packet.write(@io)
        @io.size.should == 52
        @io.size.should == packet.packet_size
      end

      it "has correct dynamic size for NLP with odd node laps"

    end

    describe "when defining a type" do

      before(:each) do
        LFS::Parser::Packet.define_packet :TEST, 8 do
          byte :ok
          byte spare
          word spare
        end
        @packet = :TEST.to_packet
      end

      it "has 2 spares" do
        @packet.snapshot.keys.select {|k| k =~ /^_sp/ }.size.should == 2
      end

    end

  end

  describe "tiny packet" do
  
    before do
      @packet = :TINY_VER.to_packet
    end

    it "is 4 bytes long" do
      @packet.to_s.size.should == 4
    end

    it "match type correctly" do
      @packet.should === :TINY
      @packet.should === :TINY_VER
    end

    it "match correct symbol type" do
      # case statement
      :TINY.should === @packet
      :TINY_VER.should === @packet
    end

  end

end
