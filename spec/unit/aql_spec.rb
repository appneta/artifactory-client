require "spec_helper"

module Artifactory::AQL
  describe "ItemQueryBuilder" do
    # it "raises error if nothing provided" do
    #   builder = ItemQueryBuilder.new
    #   expect(builder.query).to raise_error(RuntimeError)
    # end

    it "takes a single criteria" do
      builder = ItemQueryBuilder.new
      builder.with_criteria("build.name", :equals, "artifactory")
      expect(builder.query).to eq("items.find({\"@build.name\":{\"$eq\":\"artifactory\"}})")
    end

    # it "takes a several criteria" do
    #   builder = ItemQueryBuilder.new
    #   expect(builder.query).to eq("")
    # end

    # it "takes a criteria and a compound criteria" do
    #   builder = ItemQueryBuilder.new
    #   expect(builder.query).to eq("")
    # end
  end
end