require 'spec_helper'
require 'go_pipeline'

def stage(opts)
  name = opts[:name] || "any"
  default_opts = {id: "test_pipeline/18/#{name}/1", name: name, pipeline_name: "test_pipeline", status: "Success", activity: "Sleeping" }
  GoStage.new(default_opts.merge(opts))
end

def pipeline(name="any", *stages)
  pipeline = GoPipeline.new(name, http_handler).tap do |pipeline|
    stages.each {|stage| pipeline.stages << stage }
  end
end

describe "GoPipeline" do
  before { http_handler.stub(:retrieve).with("/api/pipelines/test_pipeline/stages.xml").and_return(STAGES_XML) }
  
  context "when build is green and sleeping" do
    let(:http_handler) { mock() }
    subject { pipeline("test_pipeline", stage(status: "Success"), stage(status: "Success")) }

    its(:status) { should == "passed" }
    its(:activity) { should == "sleeping" }
    its(:failed_stage) { should be_nil }
    its(:to_json) { should == {name: "test_pipeline", status: "passed", activity: "sleeping" }.to_json }
  end
  
  context "when build is red and sleeping" do
    let(:http_handler) { mock() }
    let(:failed_stage) { stage(status: "Failure", name: "stage2") }
    subject { pipeline("test_pipeline", stage(status: "Success"), failed_stage) }

    its(:status) { should == "failed" }
    its(:activity) { should == "sleeping" }
    its(:failed_stage) { should == failed_stage }
    its(:to_json) { should == {name: "test_pipeline", status: "failed", activity: "sleeping", build_breakers: ["Tom", "Dickie Bird", "rambo", "Deeldon Lemauza"] }.to_json }
  end
  
  context "when build is red and building" do
    let(:http_handler) { mock() }
    let(:failed_stage) { stage(status: "Failure", name: "stage2") }
    subject { pipeline("test_pipeline", stage(status:"Success", activity: "Building"), failed_stage) }

    its(:status) { should == "failed" }
    its(:activity) { should == "building" }
    its(:to_json) { should == {name: "test_pipeline", status: "failed", activity: "building", build_breakers: ["Tom", "Dickie Bird", "rambo", "Deeldon Lemauza"] }.to_json }
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