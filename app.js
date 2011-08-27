
/**
 * Module dependencies.
 */

var express = require('express')
  , nko = require('nko')('Vzhctm/pgoeQd99c')
  , OAuth= require('oauth').OAuth;

var oa = new OAuth("https://twitter.com/oauth/request_token",
        "https://twitter.com/oauth/access_token", 
        "vg7S2p6MSSUGxsJhDgizMw", "zsrWRYBv3e3KX7emhjAJxuwejOPRo5HfbtL5fiL26Y", 
        "1.0A", "http://192.168.100.38:8000/game/oauth/callback", "HMAC-SHA1");

var app = module.exports = express.createServer();






// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.compiler({src: __dirname + '/public', enable: ['coffeescript']}));
  app.use(require('stylus').middleware({ src: __dirname + '/public' }));
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

app.configure('production', function(){
  app.use(express.errorHandler()); 
});

// Routes

app.get('/', function(req, res){
  res.render('index', {
    title: 'Aranja'
  });
});

app.get('/oauth/authenticate', function(req, res) {
  oa.getOAuthRequestToken(function(error, oauth_token, oauth_token_secret, results) {
    if (error) new Error(error.data)
    else {
      req.session.oauth.token = oauth_token
      req.session.oauth.token_secret = oauth_token_secret
      res.redirect('https://twitter.com/oauth/authenticate?oauth_token='+oauth_token)
    }
  });
});


app.get('/oauth/callback', function(req, res, next){
  if (req.session.oauth) {
    req.session.oauth.verifier = req.query.oauth_verifier
    var oauth = req.session.oauth

    oa.getOAuthAccessToken(oauth.token,oauth.token_secret,oauth.verifier, 
      function(error, oauth_access_token, oauth_access_token_secret, results){
        if (error) new Error(error)
        console.log(results.screen_name)
	   }
	 );
  } else
    next(new Error('No OAuth information stored in the session. How did you get here?'))
  }
);

var Server = require('./gameserver/main').Server
  , server = new Server(app);
