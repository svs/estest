require 'bundler'
Bundler.setup
require 'pry'
require 'elasticsearch'
require 'awesome_print'
client = Elasticsearch::Client.new
r = rand(1000)
ap r
s = client.search index: 'test', type: 'profile', body: {query: {constant_score: {filter: { terms: { seen: [r]}}}}}
s["hits"] = s["hits"]["total"]
ap s
