require File.dirname(__FILE__) + '/spec_helper'

class Job
  extend Resque::Plugins::Stats
  @queue = :job
  def self.perform(*args)
    # work
  end
end

describe Resque::Plugins::Stats do
  describe "compliance of Resque Plugins guidelines" do
    it "should be valid" do
      lambda{ Resque::Plugin.lint(Resque::Plugins::Stats) }.should_not raise_error
    end
  end

  describe "initial status" do
    it "should return an empty hourly counter" do
      Job.hourly.should == Array.new(24, 0)
    end

    it "should return an empty daily counter" do
      daily = Job.daily
      daily.size.should <= 32 # because we start at 0
      daily.size.should >= 28
      daily.uniq.should == [0]
    end

    it "should return an empty monthly counter" do
      Job.monthly.should == {}
    end
  end

  describe "counters" do
    before do
      Resque.enqueue(Job)
      Resque::Worker.new(:job).work(0) # Work off the enqueued job
    end

    it "should increment the hourly counter" do
      hourly = Job.hourly
      hourly.size.should == 24
      hourly[Time.now.hour].should == 1
    end

    it "should increment the daily counter" do
      daily = Job.daily
      daily.size.should >= 28
      daily.size.should <= 32
      daily[Time.now.day].should == 1
    end

    it "should increment the monthly counter" do
      monthly = Job.monthly
      monthly.size.should == 1
      monthly["#{Time.now.year}:#{Time.now.month}"].should == 1
    end

    it "should increment the counter multiple times" do
      6.times { Resque.enqueue(Job) }
      Resque::Worker.new(:job).work(0)
      Job.hourly[Time.now.hour].should == 7
      Job.daily[Time.now.day].should == 7
      Job.monthly["#{Time.now.year}:#{Time.now.month}"].should == 7
    end

  end
end
