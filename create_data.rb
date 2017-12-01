require 'bundler'
Bundler.setup
require 'elasticsearch'
require 'awesome_print'

class Range
  def sample
    self.to_a.sample
  end
end

client = Elasticsearch::Client.new
ap client.cluster.health

castes = JSON.load(File.open("./castes.json"))["castes"]
jobs = JSON.load(File.open("./occupations.json"))["occupations"]
names = JSON.load(File.open("./names.json"))["names"]


client.indices.delete index: 'test' rescue nil

t = Time.new
n = 1_00
@q = Queue.new
n.times do |i|
  b = {
    memberlogin: i,
    religion: ['Yogi','Bhogi','Rogi','Jedi','Pastafarian'].sample,
    name: names.sample,
    caste: castes.sample,
    caste_number: rand(60000),
    date_of_birth: Date.today - rand(3650) - (18*365),
    height: 55 + rand(15),
    weight: 45 + rand(55),
    income: [0,1,3,6,10,20,40,60,100,1000].sample,
    marital_status: (0..3).sample,
    manglik: rand(1),
    mothertongue: rand(50),
    children: [true,false].sample,
    drink: (0..2).sample,
    smoke: (0..2).sample,
    job: jobs.sample,
    job_number: rand(111),
    diet: (0..2).sample,
    special_cases: (0..2).sample,
    screened: [true, false].sample,
    hidden: [true, false].sample,
    last_login_date: Date.today - rand(90),
  }
#  b[:seen] = (Array.new(rand(100)) { rand(100000) }).uniq.compact
  @q.push(b)
  if @q.length%1000 == 0
    p @q.length
  end
end
p "Done pushing #{n} in #{ap Time.now - t}"
@threads = Array.new(8) do
  Thread.new do
    until @q.empty? do
      l = @q.length
      o = @q.shift
      x = client.index index: 'test', type: 'profile', body: o
      if l%100 == 0
        ap "#{l} #{Time.now - t}"
      end
    end
  end
end

@threads.each(&:join)
ap Time.now - t



#ap client.search index: 'test'
