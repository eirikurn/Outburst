
/**
 * Module dependencies.
 */

var express = require('express')
  , sys = require('sys')
  //, nko = require('nko')('Vzhctm/pgoeQd99c')
  , OAuth= require('oauth').OAuth;

//var serverPath = "http://outburst.no.de";
//var serverPath = "http://192.168.100.38:8000";
var serverPath = "http://aranja.nko2.nodeknockout.com";

var oa = new OAuth("https://twitter.com/oauth/request_token",
        "https://twitter.com/oauth/access_token", 
        "vg7S2p6MSSUGxsJhDgizMw", "zsrWRYBv3e3KX7emhjAJxuwejOPRo5HfbtL5fiL26Y", 
        "1.0A", serverPath + "/oauth/callback", "HMAC-SHA1");

var app = module.exports = express.createServer();


// Configuration

app.configure(function(){
  app.use(express.cookieParser());
  app.use(express.session({secret: "mysuperdupahsicretekeeey!"}));
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.compiler({src: __dirname + '/public', enable: ['coffeescript']}));
  app.use(require('stylus').middleware({ src: __dirname + '/public' }));
  app.use(express.static(__dirname + '/public'));
  app.use(app.router);
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));

  // Cache manifest
  app.get('/cache.manifest', function(req, res) {
    res.send('dev', 404);
  });
});

app.configure('production', function(){
  app.use(express.errorHandler());

  // Cache manifest
  app.get('/cache.manifest', function(req, res) {
    fs.readFile('./files.manifest', function(err, data) {
      if(err) {
        res.send("Oops! Couldn't find that file.");
      } else {
        res.contentType('text/cache-manifest');
        res.send(data);
      }   
      res.end();
    }); 
  });
});

// Routes
app.get('/', function(req, res){
  res.render('index', { layout: false });
});

app.get('/oauth/user', function(req, res){
  console.log("Get user, wohoo");
  
  var onError = function (str) {
    console.log("Client error, " + str);
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('error');
  }
  
  if (req.session.uid) {
    oa.get('http://api.twitter.com/1/account/verify_credentials.json', req.session.accestoken, req.session.accesstokensecret, function(error, data) {
      if (!error) {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end(data);
      } else {
        onError("Could not authenticate with twitter.");
        console.log(error);
      }
    });
  } else {
    onError("No authentication token, user not logged in to twitter or no cookies.");
  }
});

app.get('/oauth/authenticate', function(req, res) {
  oa.getOAuthRequestToken(function(error, oauth_token, oauth_token_secret, results) {
    if (error) new Error(error.data)
    else {
    	req.session.oauthtoken = oauth_token
      req.session.oauthtoken_secret = oauth_token_secret
      res.redirect('https://twitter.com/oauth/authenticate?oauth_token='+oauth_token)
    }
  });
});


app.get('/oauth/callback', function(req, res, next){
  if (req.session.oauthtoken) {
    req.session.oauthverifier = req.query.oauth_verifier

    oa.getOAuthAccessToken(req.session.oauthtoken,req.session.oauthtoken_secret,req.session.oauthverifier, 
      function(error, oauth_access_token, oauth_access_token_secret, results){
        if (error) new Error(error)
        console.log(results)
        if (!results) {
        	console.log("User did not authenticate.")
        	res.redirect('/')
        } else {
        	console.log("User is authenticated!")
        	console.log(results.screen_name)
        	req.session.uid = results.user_id;
        	req.session.uname = results.screen_name;
        	req.session.accestoken = oauth_access_token;
        	req.session.accesstokensecret = oauth_access_token_secret;
        	res.redirect('/game/?loggedIn')
        }
        
	   }
	 );
  } else
    next(new Error('No OAuth information stored in the session. How did you get here?'))
  }
);




var Server = require('./gameserver/main').Server
  , server = new Server(app);
