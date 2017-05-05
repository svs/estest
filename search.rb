require 'bundler'
Bundler.setup
require 'pry'
require 'elasticsearch'
require 'awesome_print'

class Range
  def sample
    self.to_a.sample
  end
end

client = Elasticsearch::Client.new
r = rand(10000)
ap "searching for: #{r}"
stats = []
t = rand(125) + 10
caste_range = (1 + rand(5)) * 10000
job_range = rand(11) * 10

must = [
  {
    term: {
      manglik: 0
    }
  },
  {
    range: {
      caste_number: {
        gte: caste_range,
        lte: caste_range + 9999,
        boost: 2
      }
    }
  },
  {
    range: {
      date_of_birth: {
        gte: "now-27y",
        lte: "now-18y",
        boost: 2
      }
    }
  },
  {
    term: {
      income: [0,1,3,6,10,20,40,60,100,1000].sample
    }
  },
  {
    term: {
      marital_status: (0..3).sample,
    }
  },
  {
    range: {
      job_number: {
        gte: job_range,
        lte: job_range + 9,
        boost: 5
      }
    }
  },
  {
    range: {
      height: {
        gte: 52,
        lte: 66
      }
    }
  }
]



body = {
  query: {
    function_score: {
      query: {
        bool: {
          must_not: [
            term: {
              seen: r
            }
          ],
          must: []

        }
      },
      functions: [
        {
          gauss: {
            caste_number: {
              origin: caste_range + rand(500) + 250,
              scale: caste_range - 1,
              decay: 0.001
            }
          }
        }
      ]
    }
  }
}

ap body
t.times do
  s = client.search index: 'test', type: 'profile', body: body
  s["hits"] = s["hits"]["total"]
  stats << s["took"]
  ap "took #{s["took"]} ms for #{s["hits"]} hits"
end
ap stats.reduce(:+)/(t * 1.0)
