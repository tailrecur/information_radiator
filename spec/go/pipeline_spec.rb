require 'spec_helper'
require 'go/pipeline'
require 'stringio'

describe "GoPipeline" do
  
  let(:http_handler) { mock() }
  before { http_handler.stub(:retrieve).with("/api/pipelines/test_pipeline/stages.xml").and_return(STAGES_XML) }
  
  def stage(opts)
    name = opts[:name] || "stage3"
    default_opts = {id: "test_pipeline/18/#{name}/1", name: name, pipeline_name: "test_pipeline", status: "Success", activity: "Sleeping", label: "P2" }
    GoStage.new(default_opts.merge(opts))
  end

  def pipeline(name="any", *stages)
    pipeline = GoPipeline.new(name, http_handler).tap do |pipeline|
      stages.each {|stage| pipeline.stages << stage }
    end
  end
  
  context "when build is green and sleeping" do
    subject { pipeline("test_pipeline", stage(status: "Success"), stage(status: "Success")) }

    its(:status) { should == "passed" }
    its(:activity) { should == "sleeping" }
    its(:failed_stage) { should be_nil }
    its(:to_json) { should == {name: "test_pipeline", status: "passed", activity: "sleeping", label: "P2" }.to_json }
  end
  
  context "when build is red" do
    let(:failed_stage) { stage(status: "Failure", name: "stage2") }

    context "when sleeping and broken" do
      subject { pipeline("test_pipeline", stage(status: "Success"), failed_stage) }
      before{ subject.refresh_data }

      its(:status) { should == "failed" }
      its(:activity) { should == "sleeping" }
      its(:failed_stage) { should == failed_stage }
      its(:to_json) { should == {name: "test_pipeline", status: "failed", activity: "sleeping", label: "P2", triggerer: nil, buildBreakers: ["Tom", "Dickie Bird", "rambo", "Deeldon Lemauza"] }.to_json }
    end
    
    context "when building and triggered" do
      subject { pipeline("test_pipeline", stage(status:"Success", activity: "Building"), failed_stage, stage(name: "stage1")) }
      before{ subject.refresh_data }

      its(:status) { should == "failed" }
      its(:activity) { should == "building" }
      its(:to_json) { should == {name: "test_pipeline", status: "failed", activity: "building", label: "P2", triggerer: "rambo", buildBreakers: ["Tom", "Dickie Bird", "rambo", "Deeldon Lemauza"] }.to_json }
    end
    
    context "when stages API fails" do
      before { $stdout = StringIO.new }
      before { http_handler.stub(:retrieve).with("/api/pipelines/test_pipeline/stages.xml").and_raise(Exception.new("some error")) }
      let(:failed_stage) { stage(status: "Failure", name: "stage2") }
      subject { pipeline("test_pipeline", stage(status: "Success"), failed_stage) }
      before{ subject.refresh_data }
      
      its(:status) { should == "failed" }
      its(:activity) { should == "sleeping" }
      its(:failed_stage) { should == failed_stage }
      # its(:to_json) { should == {name: "test_pipeline", status: "failed", activity: "sleeping", triggerer: nil, buildBreakers: [] }.to_json }
    end
  end
  

STAGES_XML = <<-STAGE
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:go="http://www.thoughtworks-studios.com/ns/go">
  <entry>
      <id>http://go.server/go/pipelines/test_pipeline/18/stage3/1</id>
      <author>
          <name><![CDATA[Tom <tom@gmail.com>]]></name>
      </author>
  </entry>
  <entry>
      <id>http://go.server/go/pipelines/test_pipeline/18/stage2/1</id>
      <author>
          <name><![CDATA[Tom <tom.mail@gmail.com>]]></name>
      </author>
      <author>
          <name><![CDATA[Dickie Bird <dickie.bird@hotmail.com>]]></name>
      </author>
      <author>
          <name><![CDATA[rambo <rambo@gmail.com>]]></name>
      </author>
      <author>
          <name><![CDATA[Deeldon Lemauza <dee@map.com>]]></name>
      </author>
  </entry>
  <entry>
      <id>http://go.server/go/pipelines/test_pipeline/18/stage1/1</id>
      <go:author>
          <go:name><![CDATA[rambo]]></go:name>
      </go:author>
      <author>
          <name><![CDATA[Tom <abc.any@gmail.com>]]></name>
      </author>
      <author>
          <name><![CDATA[Dickie Bird <foo.march@hotmail.com>]]></name>
      </author>
  </entry>
</stage>
STAGE

end