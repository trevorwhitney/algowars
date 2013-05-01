require 'spec_helper'
require "#{File.dirname(__FILE__)}/../divider.rb"

describe Divider do
  context "Given a valid input is provided" do
    context "When the input is n = [1 7 92 93 121 179 211]" +
        " and m = [2 5 9]" do
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
        @divider.completion_time[:time].should == 50
        @divider.to_s.should == "1 0 2\n" +
          "3 4\n" +
          "6 5\n" +
          "50.00"
      end
    end

    context "When the input is n = [1, 2, 4, 6, 8, 12, 100, 200, 600]" +
      " and m = [1, 2, 4, 20]" do
      before :all do
        input = File.open("#{File.dirname(__FILE__)}/../tmp/input.txt", "w")
        input.write "9\n"
        input.write "4\n"
        input.write "1, 2, 4, 6, 8, 12, 100, 200, 600\n"
        input.write "1, 2, 4, 20"
        input.close
        @divider = Divider.new(input.path)
      end

      it "should correctly parse the times" do
        @divider.n.should == 9
        @divider.times.should == [1, 2, 4, 6, 8, 12, 100, 200, 600]
      end

      it "should correctly parse the machine speeds" do
        @divider.m.should == 4
        @divider.speeds.should == [1, 2, 4, 20]
      end

      it "should generate the correct groups" do
        groups = @divider.generate_groups
        groups[0].should == [1,2]
        groups[1].should == [4,6]
        groups[2].should == [8,12]
        groups[3].should == [100, 200, 600]
      end

      it "should find the optimal time of 40" do
        @divider.completion_time[:time].should == 40
      end
    end

    context "When the input is n = [2, 40, 80, 82, 84, 90]" +
      " and m = [2, 4, 6]" do
      before :all do
        input = File.open("#{File.dirname(__FILE__)}/../tmp/input.txt", "w")
        input.write "6\n"
        input.write "3\n"
        input.write "2, 40, 80, 82, 84, 90\n"
        input.write "2, 4, 6"
        input.close
        @divider = Divider.new(input.path)
      end

      it "should correctly parse the times" do
        @divider.n.should == 6
        @divider.times.should == [2, 40, 80, 82, 84, 90]
      end

      it "should correctly parse the machine speeds" do
        @divider.m.should == 3
        @divider.speeds.should == [2, 4, 6]
      end

      it "should generate the correct groups" do
        groups = @divider.generate_groups
        groups[0].should == [2,40]
        groups[1].should == [80,82]
        groups[2].should == [84,90]
      end

      it "should find the optimal time of 40" do
        @divider.completion_time[:time].should == 40.5
      end
    end

    context "When the input is n = [1, 2, 3, 40, 70, 100, 120, 150, 180]" +
      " and m = [1, 10, 30]" do
      before :all do
        input = File.open("#{File.dirname(__FILE__)}/../tmp/input.txt", "w")
        input.write "9\n"
        input.write "3\n"
        input.write "1, 2, 3, 40, 70, 100, 120, 150, 180\n"
        input.write "1, 10, 30"
        input.close
        @divider = Divider.new(input.path)
      end

      it "should correctly parse the times" do
        @divider.n.should == 9
        @divider.times.should == [1, 2, 3, 40, 70, 100, 120, 150, 180]
      end

      it "should correctly parse the machine speeds" do
        @divider.m.should == 3
        @divider.speeds.should == [1, 10, 30]
      end

      it "should generate the correct groups" do
        groups = @divider.generate_groups
        groups[0].should == [1,2,3]
        groups[1].should == [40,70,100]
        groups[2].should == [120,150,180]
      end

      it "should find the optimal time of 46" do
        @divider.completion_time[:time].should == 46
      end

      it "should find the optimal time of 17 when using task time " +
          "as the decision" do
        @divider.completion_time(:decision => :task_time)[:time].should == 17
      end

      it "should pick 17 as the optimal time" do
        @divider.find_best_time[:time].should == 17
      end
    end

    context "When the input is n = [1, 2, 4, 8, 400, 800]" +
        " and m = [1, 2, 40]" do
      before :all do
        input = File.open("#{File.dirname(__FILE__)}/../tmp/input.txt", "w")
        input.write "6\n"
        input.write "3\n"
        input.write "1, 2, 4, 8, 400, 800\n"
        input.write "1, 2, 40"
        input.close
        @divider = Divider.new(input.path)
      end

      it "should correctly parse the times" do
        @divider.n.should == 6
        @divider.times.should == [1, 2, 4, 8, 400, 800]
      end

      it "should correctly parse the machine speeds" do
        @divider.m.should == 3
        @divider.speeds.should == [1, 2, 40]
      end

      it "should generate the correct groups" do
        groups = @divider.generate_groups
        groups[0].should == [1,2]
        groups[1].should == [4,8]
        groups[2].should == [400,800]
      end

      it "should find the optimal time of 30" do
        @divider.completion_time[:time].should == 30
      end
    end
  end
end