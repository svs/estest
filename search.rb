require 'bundler'
Bundler.setup
require 'pry'
require 'elasticsearch'
require 'awesome_print'
client = Elasticsearch::Client.new
r = rand(1000)
ap "searching for: #{r}"
5.times do
  s = client.search index: 'test', type: 'profile', body: {
                      query: {
                        bool: {
                          must_not: {
                            term: {
                              seen: r
                            }
                          }
                        }
                      }
                    }
  s["hits"] = s["hits"]["total"]
  ap "took #{s["took"]} ms for #{s["hits"]} hits"
end
