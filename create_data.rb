require 'bundler'
Bundler.setup
require 'elasticsearch'
require 'awesome_print'

client = Elasticsearch::Client.new
ap client.cluster.health

castes = JSON.load(File.open("./castes.json"))["castes"]
jobs = JSON.load(File.open("./occupations.json"))["occupations"]
names = JSON.load(File.open("./names.json"))["names"]


client.indices.delete index: 'test'

t = Time.new
1_00_000.times do |i|
  b = {name: names.sample, caste: castes.sample, job: jobs.sample}
  b[:seen] = (Array.new(rand(1000)) { rand(1000) }).uniq.compact
  x = client.index index: 'test', type: 'profile', body: b
  if i%100 == 0
    ap i
  end
end
ap Time.now - t
#ap client.search index: 'test'
