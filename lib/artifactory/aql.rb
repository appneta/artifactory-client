#
# Copyright 2014-2018 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Artifactory
  module AQL
    # https://www.jfrog.com/confluence/display/JFROG/Artifactory+Query+Language#ArtifactoryQueryLanguage-FieldCriteria
    class Criteria
      attr_accessor :field, :op, :value

      def initialize((field, op, value))
        # https://www.jfrog.com/confluence/display/JFROG/Artifactory+Query+Language#ArtifactoryQueryLanguage-SupportedDomains
        @field = field
        # https://www.jfrog.com/confluence/display/JFROG/Artifactory+Query+Language#ArtifactoryQueryLanguage-ComparisonOperators
        @op = op # also takes :not_equals
        @value = value
      end

      def build
        "\"" + @field + "\":{\"$" + @op.to_s + "\":\"" + @value +"\"}"
      end
    end

    # https://www.jfrog.com/confluence/display/JFROG/Artifactory+Query+Language#ArtifactoryQueryLanguage-CompoundingCriteria
    class CompoundCriteria
      attr_accessor :criterias, :op

      def initialize((op, c))
        # https://www.jfrog.com/confluence/display/JFROG/Artifactory+Query+Language#ArtifactoryQueryLanguage-CompoundingCriteria
        @op = op
        @criterias = c.map { |crit| process_criteria(crit) }
        @translated = []
      end

      def process_criteria(c)
        if c.length() == 3
          Criteria.new(c)
        elsif c.length() == 2
          CompoundCriteria.new(c)
        else
          raise "Invalid input"
        end
      end

      def build
        @criterias.each { |c| @translated.push("{" + c.build + "}") }
        "\"$" + @op.to_s + "\":[" + @translated.join(",") +"]"
      end
    end

    class ItemQueryBuilder
      attr_accessor :type, :query

      def initialize
        @criterias = []
        @translated = []
        @query = ""
      end

      def with_criteria((f, op, v))
        @criterias << Criteria.new([f, op, v])
      end

      def with_compound_criteria((op, c))
        @criterias << CompoundCriteria.new([op, c])
      end

      def process_criteria(c)
        @translated.push(c.build)
      end

      def build
        @query = "items.find({"
        @criterias.each { |c| process_criteria(c) }
        translated = @translated.join(",")
        @query << translated
        @query += "})"
        @query
      end

      def query
        raise 'No criteria added' if @criterias.length() == 0
        build
      end
    end
  end
end