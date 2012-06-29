Fs           = require('fs')
Net          = require('net')
Phantom      = require('phantom')
EventEmitter = require('events').EventEmitter

class Pingmeister extends EventEmitter

  constructor: (@config) ->

  run: () ->
    console.log "Create worker"
    Phantom.create (worker) =>
      for tag, url of @config.urls
        do (tag) =>
          worker.createPage (page) =>
            console.log "Starting a new test for url #{@config.urls[tag]}"
            start = Date.now()
            page.open @config.urls[tag], (status) =>
              if status != 'success'
                console.log  "FAILED: #{url}"
              else
                now         = Date.now()
                taken       = now - start
                metric_line = "Pingmeister.load_time.#{@config.id}.#{tag} #{taken} #{now/1000}"
                console.log "SUCCESS: #{@config.urls[tag]} in #{taken}"
                @send metric_line
              worker.exit()

  send: (line) ->
    conn = Net.connect @config.carbon.port, @config.carbon.host
    conn.addListener 'error', (error) =>
      console.log "Connection error: #{error}"
    conn.on 'connect', () =>
      try
        console.log "Sending metrics"
        conn.write "#{line}\n"
      catch error
        console.log "Failed to send data: #{error}"
        throw new Error "Failed to send data: #{error}"
      finally
        conn.end()


module.exports = Pingmeister
