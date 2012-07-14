require 'spec_helper'
require 'http_handler'
require 'go_monitor'
require 'stringio'

CCTRAY_XML = <<XML
<Projects>
  <Project name="test_pipeline :: stage1" activity="Sleeping" lastBuildStatus="Success" webUrl="http://go.server/go/pipelines/test_pipeline/1/stage1/1"></Project>
  <Project name="test_pipeline :: stage1 :: job" activity="Sleeping" lastBuildStatus="Success" webUrl="http://go.server/go/pipelines/test_pipeline/1/stage1/1/job"></Project>
  <Project name="test_pipeline :: stage2" activity="Sleeping" lastBuildStatus="Success" webUrl="http://go.server/go/pipelines/test_pipeline/1/stage2/1"></Project>
  <Project name="test2_pipeline :: stage" activity="Sleeping" lastBuildStatus="Success" webUrl="http://go.server/go/pipelines/test2_pipeline/1/stage/1"></Project>
</Projects>
XML

describe GoMonitor do
  subject { GoMonitor.new(Hashie::Mash.new(url: "http://go.server", pipelines: {inclusions: ["test_pipeline", "test2_pipeline"]})) }

  describe "#refresh_rate" do
    context "when not specified" do
      its(:refresh_rate) { should == 15 }
    end
    
    context "when specified" do
      subject { GoMonitor.new(Hashie::Mash.new(url: "http://go.server", refresh_rate: 30, pipelines: {inclusions: ["any"]})) }
      its(:refresh_rate) { should == 30 }
    end
  end
  
  describe "#refresh_data" do
    context "when basic auth is not specified" do
      it "should retrieve xml" do
        http_handler = mock()
        HttpHandler.should_receive(:new).with("http://go.server/go").and_return(http_handler)
        http_handler.should_receive(:auth).never
        http_handler.should_receive(:retrieve).with("/cctray.xml").and_return(CCTRAY_XML)
        pipelines = subject.refresh_data
      end
    end

    context "when basic auth is specified" do
      subject { GoMonitor.new(Hashie::Mash.new(url: "http://go.server", username: "foo", password: "bar", pipelines: {inclusions: ["test_pipeline", "test2_pipeline"]})) }
      it "should retrieve xml" do
        http_handler = mock()
        HttpHandler.should_receive(:new).with("http://go.server/go").and_return(http_handler)
        http_handler.should_receive(:auth).with("foo", "bar")
        http_handler.should_receive(:retrieve).with("/cctray.xml").and_return(CCTRAY_XML)
        pipelines = subject.refresh_data
        pipelines.size.should == 2
        pipelines.first.stages.size.should == 2
        pipelines.last.stages.size.should == 1
        stage = pipelines.last.stages.first
        stage.should_not be_failed
        stage.should_not be_building
      end
    end
    
    context "when go server is down" do
      it "should return error" do
        http_handler = mock()
        HttpHandler.should_receive(:new).with("http://go.server/go").and_return(http_handler)
        http_handler.should_receive(:auth).never
        http_handler.should_receive(:retrieve).with("/cctray.xml").and_raise(Exception.new("Connection Error"))
        $stdout = StringIO.new
        expect { subject.refresh_data }.to raise_error("Cannot connect to GO server")
      end
    end
  end
end
