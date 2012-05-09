##
# Dependencies
##
express = require('express')
RedisStore = require('connect-redis')(express)
OAuth = require('oauth').OAuth
fs    = require('fs')
path  = require('path')

class exports.Server
  constructor: (@app) ->
    @configure()
    @setupOAuth()

    @app.get '/cache.manifest', @cacheManifest
    @app.get '/', @index
    @app.get '/oauth/user', @oauthUser
    @app.get '/oauth/authenticate', @oauthAuthenticate
    @app.get '/oauth/callback', @oauthCallback

  configure: ->
    # Settings
    @app.set 'views', __dirname + '/../views'
    @app.set 'view engine', 'jade'
    @app.set 'view options', { layout: false }
    @app.set 'serverPath', "http://www.outburstgame.com"
    @app.configure 'development', =>
      @app.set 'errorHandler', { dumpExceptions: true, showStack: true }
    @app.configure 'production', =>
      @app.set 'errorHandler', {}

    try
      json = fs.readFileSync __dirname + '/locals.json', "utf8"
      for k, val of JSON.parse(json)
        @app.set k, val
    catch e # Ignore errors if locals doesn't exist
      throw e if e.code not in ["EBADF", "ENOENT"]

    # Middleware
    @app.use express.bodyParser()
    @app.use express.methodOverride()
    @app.use express.cookieParser()

    # Store session in Redis
    store = null
    if process.env.REDISTOGO_URL
      # Read redis configuration from env
      redisConfig = /redis:\/\/(\w+):(.*)@(.*):(\d+)/.exec(process.env.REDISTOGO_URL)
      store = new RedisStore(
        host: redisConfig[3]
        port: redisConfig[4]
        pass: redisConfig[2]
      )
    else
      store = new RedisStore()

    @app.use express.session(
      store: store
      secret: "mysuperdupahsicretekeeey!"
      cookie:
        path: '/'
        domain: 'outburstgame.com'
        maxAge: 24 * 60 * 60 * 1000
    )

    @app.use express.compiler({src: __dirname + '/../public', enable: ['coffeescript']})
    @app.use require('stylus').middleware({ src: __dirname + '/../public' })
    @app.use express.static(__dirname + '/../public')
    @app.use express.errorHandler(@app.set('errorHandler'))

  setupOAuth: ->
    @oa = new OAuth("https://twitter.com/oauth/request_token",
            "https://twitter.com/oauth/access_token",
            "vg7S2p6MSSUGxsJhDgizMw", "zsrWRYBv3e3KX7emhjAJxuwejOPRo5HfbtL5fiL26Y",
            "1.0A", @app.set('serverPath') + "/oauth/callback", "HMAC-SHA1")

  cacheManifest: (req, res) =>
    if @app.set('env') == 'production'
      res.sendfile path.join(__dirname, '../files.manifest')
    else
      res.send 'dev', 404

  index: (req, res) ->
    # Redirect old domain
    if req.headers.host == "outburst.thorsteinsson.is"
      return res.redirect(@app.set('serverPath'))

    res.render 'index', { layout: false }

  oauthUser: (req, res) =>
    onError = (str) ->
      console.log("Client error, " + str)
      res.writeHead(200, {'Content-Type': 'text/plain'})
      res.end('error')

    unless req.session.uid
      return onError("No authentication token, user not logged in to twitter or no cookies.")

    apiUrl = 'http://api.twitter.com/1/account/verify_credentials.json'
    token = req.session.accesstoken
    secret = req.session.accesstokensecret
    @oa.get apiUrl, token, secret, (error, data) ->
      if !error
        res.writeHead(200, {'Content-Type': 'text/plain'})
        res.end(data)
      else
        onError("Could not authenticate with twitter.")

  oauthAuthenticate: (req, res, next) =>
    @oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
      return next(error) if error

      req.session.oauthtoken = oauth_token
      req.session.oauthtoken_secret = oauth_token_secret
      res.redirect 'https://twitter.com/oauth/authenticate?oauth_token=' + oauth_token

  oauthCallback: (req, res, next) =>
    if !req.session.oauthtoken
      return next(new Error('No OAuth information stored in the session. How did you get here?'))

    token = req.session.oauthtoken
    secret = req.session.oauthtoken_secret
    verifier = req.session.oauthverifier = req.query.oauth_verifier

    @oa.getOAuthAccessToken token, secret, verifier, (err, token, secret, results) ->
      return next(err) if err

      if !results
        console.log("User did not authenticate.")
        res.redirect('/')
      else
        console.log("User is authenticated!", results.screen_name)
        req.session.uid = results.user_id
        req.session.uname = results.screen_name
        req.session.accesstoken = token
        req.session.accesstokensecret = secret
        res.redirect('/game/?loggedIn')
