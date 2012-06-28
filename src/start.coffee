Fs           = require('fs')
Phantom      = require('phantom')
EventEmitter = require('events').EventEmitter

class Pingmeister extends EventEmitter

  constructor: (@config) ->

  run: () ->
      console.log "Create worker"
      for url in @config.urls
        do (url) ->
          Phantom.create (worker) ->
            do (url) ->
              worker.createPage (page) ->
                console.log "Starting a new test for url #{url}"
                start = Date.now()
                page.open url, (status) ->
                  if status != 'success'
                    console.log  "FAILED: #{url}"
                  else
                    taken = Date.now() - start
                    console.log "SUCCESS: #{url} in #{taken}"
                  worker.exit()

module.exports = Pingmeister
