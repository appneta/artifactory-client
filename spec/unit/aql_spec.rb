require "spec_helper"

module Artifactory::AQL
  describe "ItemQueryBuilder" do
    it "takes a single criteria" do
      builder = ItemQueryBuilder.new
      builder.with_criteria(["@build.name", :eq, "artifactory"])
      expect(builder.query).to eq("items.find({\"@build.name\":{\"$eq\":\"artifactory\"}})")
    end

    it "takes a several criteria" do
      builder = ItemQueryBuilder.new
      builder.with_criteria(["@build.name", :eq, "artifactory"])
      builder.with_criteria(["@build.number", :ne, "123"])
      expect(builder.query).to eq("items.find({\"@build.name\":{\"$eq\":\"artifactory\"},\"@build.number\":{\"$ne\":\"123\"}})")
    end

    it "takes a criteria and a compound criteria" do
      builder = ItemQueryBuilder.new
      builder.with_criteria(["build.name", :eq, "artifactory"])
      builder.with_compound_criteria(
        [:or, 
          [
            ["artifact.module.build.param", :eq, "maven+example"], 
            ["artifact.module.build.number", :ne, "123"]
          ]
        ])
      expected = "items.find({\"build.name\":{\"$eq\":\"artifactory\"},\"$or\":[{\"artifact.module.build.param\":{\"$eq\":\"maven+example\"}},{\"artifact.module.build.number\":{\"$ne\":\"123\"}}]})"
      expect(builder.query).to eq(expected)
    end
  end
end