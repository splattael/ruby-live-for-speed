require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe LFS::Parser::Types do
  describe "Time" do
    class String
      def duration
        ms = 0
        scan(/(\d+)(ms|s|m|h|)/) do |digit, type|
          digit = digit.to_i
          ms += case type
          when "", "ms";  digit
          when "s";       digit * 1000
          when "m";       digit * 60 * 1000
          when "h";       digit * 60 * 60 * 1000
          end
        end
        ms
      end
    end

    before(:all) do
      @human_time = LFS::Parser::Types::Time.new.method(:human_time)
    end

    it "string duration" do
      "".duration.should == 0
      "1".duration.should == 1
      "1ms".duration.should == 1
      "1s".duration.should == 1000
      "1m".duration.should == 60000
      "1h".duration.should == 3600000
      "1h1m1s1ms".duration.should == 3600000 + 60000 + 1000 + 1
      "1h 1m 1s 1ms".duration.should == 3600000 + 60000 + 1000 + 1
      "3h 25m 53s 200ms".duration.should == 3 * 3600000 + 25 * 60000 + 53 * 1000 + 200
    end

    it "have human_time method" do
      @human_time.class.should == Method
    end

    it "display nothing for nil time" do
      @human_time.call(nil).should == ""
    end

    it "displays human time" do
      display = {
        "0"           =>  "00:00.000",
        "1"           =>  "00:00.001",
        "1s1"         =>  "00:01.001",
        "1m1s1"       =>  "01:01.001",
        "1h1m1s1"     =>  "01:01:01.001",
        "24h 3s 354"  =>  "24:00:03.354",
      }
      display.each do |input, expected|
        @human_time.call(input.duration).should == expected
      end
    end

  end
end
