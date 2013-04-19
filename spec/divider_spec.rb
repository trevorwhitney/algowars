require 'spec_helper'
require "#{File.dirname(__FILE__)}/../divider.rb"

describe Divider do
  context "Given a valid input is provided" do
    context "When the input of n = [1 7 92 93 121 179 211]" +
        "and m = [2 5 9]" do
      before :all do
        input = File.open("#{File.dirname(__FILE__)}/../tmp/input.txt", "w")
        input.write "7\n"
        input.write "3\n"
        input.write "1 7 92 93 121 179 211\n"
        input.write "2 5 9"
        input.close
        @divider = Divider.new(input.path)
      end
      
      it "should correctly parse the times" do
        @divider.n.should == 7
        @divider.times.should == [1, 7, 92, 93, 121, 179, 211]
      end

      it "should correctly parse the machine speeds" do
        @divider.m.should == 3
        @divider.speeds.should == [2, 5, 9]
      end

      it "should generate the correct groups" do
        groups = @divider.generate_groups
        groups[0].should == [1, 7]
        groups[1].should == [92, 93]
        groups[2].should == [121, 179, 211]
      end


      it "should find the optimal time of 50" do
        @divider.completion_time.should == 50
      end
    end
  end
end