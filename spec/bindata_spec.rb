require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class BinaryString < BinData::MultiValue
  endian :little

  uint8 :len, :value => proc { data.length }
  string :data, :read_length => :len
end

describe "A binary string" do
  before do
    @io = StringIO.new
  end

  describe "class" do
    it "should subclass BinData::Struct" do
      BinaryString.superclass.should == BinData::MultiValue
    end
  end

  describe "with an empty instance" do
    before do
      @binary_string = BinaryString.new
    end

    it "should have empty data" do
      @binary_string.data.should == ""
    end

    it "should be zero sized" do
      @binary_string.len.should == 0
    end

    it "should write empty binary data with zero length" do
      @binary_string.write(@io)
      @io.size.should == 1
      @io.string.should == "\000"
    end

    it "should read empty binary data" do
      @io.write("\000")
      @io.rewind
      @binary_string.read(@io)
      @binary_string.len.should == 0
      @binary_string.data.should == ""
    end
  end

  describe "with a non empty instance" do
    before do
      @binary_string = BinaryString.new
      @binary_string.data = "hello world"
    end

    it "should have non empty data" do
      @binary_string.data.should == "hello world"
    end

    it "should have non zero length" do
      @binary_string.len.should == 11
    end

    it "should write non empty binary data" do
      @binary_string.write(@io)
      @io.size.should == 12
      @io.string.should == "\vhello world"
    end

    it "should read non empty binary data" do
      @io.write("\vhello world")
      @io.rewind
      @binary_string.read(@io)
      @binary_string.len.should == 11
      @binary_string.data.should == "hello world"
    end
  end
end
