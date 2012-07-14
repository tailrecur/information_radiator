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
  context "when build is green and sleeping" do
    let(:http_handler) { mock() }
    subject { pipeline("test_pipeline", stage(status: "Success"), stage(status: "Success")) }
    its(:status) { should == "passed" }
    its(:activity) { should == "sleeping" }
    its(:failed_stage) { should be_nil }
  end
  
  context "when build is red and sleeping" do
    let(:http_handler) { mock() }
    let(:failed_stage) { stage(status: "Failure", name: "stage2") }
    subject { pipeline("test_pipeline", stage(status: "Success"), failed_stage) }
    its(:status) { should == "failed" }
    its(:activity) { should == "sleeping" }
    its(:failed_stage) { should == failed_stage }
    
    it "should populate build breakers" do
      http_handler.should_receive(:retrieve).with("/api/pipelines/test_pipeline/stages.xml").and_return(STAGES_XML)
      subject.build_breakers.should == ["Tom", "Dickie Bird", "rambo", "Deeldon Lemauza"]
    end
  end
  
  context "when build is red and building" do
    let(:http_handler) { mock() }
    subject { pipeline("test_pipeline", stage(status:"Success", activity: "Building"), stage(status: "Failure")) }
    its(:status) { should == "failed" }
    its(:activity) { should == "building" }
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