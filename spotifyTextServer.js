var twilio = require('twilio');
var http = require('http');
var net = require('net');
var qs = require('querystring')

var currentPlayerConnection = -1;

var userNames = {};

var echonestApiKey = 'ayo! get your own Echonest API key!';

var echonestUrl = '208.43.117.65-static.reverse.softlayer.com';
var echonestSearchPath = '/api/v4/song/search?';
var echonestTrackProfilePath = '/api/v4/song/profile?';
var echonestTasteCreatePath = '/api/v4/catalog/create';
var echonestTasteAddPath = '/api/v4/catalog/update';
var tasteProfileId = 'CAGGUUV141D219A690';

//I pity thee who ventures past this point, or before this point
//(like seriously, I apologize)

var tasteCreateData = qs.stringify({
    api_key: echonestApiKey,
    format: 'json',
    type: 'song',
    name: 'sessionTasteProfile'
});

var requestOptions = {
    host: echonestUrl,
    port: 80,
    path: echonestTasteCreatePath,
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(tasteCreateData)
    }
}

var tasteProfileReq = http.request(requestOptions, function(echonestRes) {
    var echonestResBody = '';
    echonestRes.on('data', function(chunk) {
        echonestResBody += chunk;
    });
    echonestRes.on('end', function() {
        echonestResBody = JSON.parse(echonestResBody);
        console.log(echonestResBody);
    });
});
tasteProfileReq.write(tasteCreateData);
tasteProfileReq.end();

var twilioServer = http.createServer(function(req, res) {
	console.log('got a twilio request');

    var twiml = new twilio.TwimlResponse();

    var body = '';
    req.on('data', function(chunk) {
    	body += chunk;
    })
    req.on('end', function() {
    	var messageInfo = qs.parse(body);
    	var senderUserName = '';
    	if(messageInfo.From in userNames) {
    		senderUserName = userNames[messageInfo.From];
    	}
    	var command = messageInfo.Body.substring(0, messageInfo.Body.indexOf(' ')).toLowerCase();

        if(command === '') {
            command = messageInfo.Body.toLowerCase();
        }

        console.log('Command : ' + command);    

    	var commandParameter = messageInfo.Body.substring(messageInfo.Body.indexOf(' ') + 1);
    	switch(command) {
    		case 'name': {
    			userNames[messageInfo.From] = commandParameter;
    			twiml.sms('Your name is now set as ' + commandParameter);
                res.end(twiml.toString());
    			break;
    		}
    		case 'top' : {
    			if(currentPlayerConnection == -1) {
    				twiml.sms('Sorry, there isn\'t a player connected :(');
                    res.end(twiml.toString());
    			} else{
    				 var requestOptions = {
    				 	host: echonestUrl,
    				 	port: 80,
    				 	path: echonestSearchPath + qs.stringify({api_key: echonestApiKey, artist: commandParameter, results: 1, limit: true, sort: 'song_hotttnesss-desc', bucket: ['id:spotify-WW', 'tracks']}),
    				 	method: 'GET'
    				 };
                     console.log(requestOptions.path);
    				 var searchRequest = http.request(requestOptions, function(echonestRes) {
                        var echonestResBody = '';
                        echonestRes.on('data', function(chunk) {
                            echonestResBody += chunk;
                        });
                        echonestRes.on('end', function() {
                            echonestResBody = JSON.parse(echonestResBody);
                            if(!'songs' in echonestResBody.response) {
                                twiml.sms('No results for that artist were found :(');
                                res.end(twiml.toString());
                            } else{
                                console.log(echonestResBody);
                                if(echonestResBody.response.songs.length === 0 || !'tracks' in echonestResBody.response.songs[0] || echonestResBody.response.songs[0].tracks.length === 0) {
                                    twiml.sms('I can\'t find that artist :(');
                                    res.end(twiml.toString());
                                } else{
                                    if(echonestResBody.response.songs[0].tracks[0] == undefined) {
                                        twiml.sms('Looks like that artist isn\'t available on Spotify :(');
                                        res.end(twiml.toString());
                                    } else{
                                        var song = echonestResBody.response.songs[0];
                                        twiml.sms('Adding \'' + song.title + '\' to the queue!');
                                        var spotifyUrl = echonestResBody.response.songs[0].tracks[0].foreign_id;
                                        spotifyUrl = spotifyUrl.split(':')[0].split('-')[0] + ':' + spotifyUrl.split(':').slice(1).join(':');

                                        var echonestId = echonestResBody.response.songs[0].id;
                                        var requestOptions = {
                                            host: echonestUrl,
                                            port: 80,
                                            path: echonestTrackProfilePath + qs.stringify({api_key: echonestApiKey, id: echonestId, bucket: 'audio_summary'}),
                                            method: 'GET'
                                        };
                                        var audioSummaryRequest = http.request(requestOptions, function(echonestRes) {
                                            var echonestResBody = '';
                                            echonestRes.on('data', function(chunk) {
                                                echonestResBody += chunk;
                                            });
                                            echonestRes.on('end', function() {
                                                echonestResBody = JSON.parse(echonestResBody);
                                                if(!'track' in echonestResBody) {
                                                    twiml.sms('There was an error :(');
                                                } else{
                                                    var audioSummary = echonestResBody.response.songs[0].audio_summary;
                                                    /*
                                                    console.log(echonestResBody.response.songs[0].id);

                                                    var tasteAddData = qs.stringify({
                                                        api_key: echonestApiKey,
                                                        id: tasteProfileId,
                                                        data : [{
                                                            action: 'update',
                                                            item: {
                                                                item_id: echonestResBody.response.songs[0].id
                                                            }
                                                        }]                                                    
                                                    });

                                                    var tasteAddRequestOptions = {
                                                        host: echonestUrl,
                                                        port: 80,
                                                        path: echonestTasteAddPath,
                                                        method: 'POST',
                                                        headers: {
                                                            'content-type': 'application/x-www-form-urlencoded',
                                                            'content-length': Buffer.byteLength(tasteAddData)
                                                        }
                                                    }

                                                    var tasteProfileAddReq = http.request(tasteAddRequestOptions, function(echonestTasteAddRes) {
                                                        var echonestTasteCreateResBody = '';
                                                        echonestTasteAddRes.on('data', function(chunk) {
                                                            echonestTasteCreateResBody += chunk;
                                                        });
                                                        echonestTasteAddRes.on('end', function() {
                                                            echonestResBody = JSON.parse(echonestTasteCreateResBody);
                                                            console.log(echonestTasteCreateResBody);
                                                        });
                                                    });
                                                    tasteProfileAddReq.write(tasteAddData);
                                                    tasteProfileAddReq.end();
                                                    */

                                                    currentPlayerConnection.write(JSON.stringify({command: 'queueTrack', url: spotifyUrl, summary: audioSummary, sender: senderUserName}) + '\n');
                                                }
                                            });
                                            res.end(twiml.toString());            
                                        }).end();
                                    }
                                }
                            }
                            res.end(twiml.toString());
                        });
                     }).end();
    			}
                break;
    		}
    		case 'song' : {
    			if(currentPlayerConnection == -1) {
    				twiml.sms('Sorry, there isn\'t a player connected :(');
                    res.end(twiml.toString());
    			} else{
                    songName = commandParameter.split('$')[0];
                    artistName = commandParameter.split('$')[1];
                    var requestOptions = {
                        host: echonestUrl,
                        port: 80,
                        path: echonestSearchPath + qs.stringify({api_key: echonestApiKey, title: songName, results: 1, limit: true, sort: 'artist_hotttnesss-desc', bucket: ['id:spotify-WW', 'tracks']}),
                        method: 'GET'
                     };
                     if(artistName != undefined && artistName.replace(/\s+/g, ' ') !== '') {
                        requestOptions.path += '&' + qs.stringify({artist: artistName});
                     }
                     var request = http.request(requestOptions, function(echonestRes) {
                        var echonestResBody = '';
                        echonestRes.on('data', function(chunk) {
                            echonestResBody += chunk;
                        });
                        console.log(requestOptions.path);
                        echonestRes.on('end', function() {
                            echonestResBody = JSON.parse(echonestResBody);
                            if(!'songs' in echonestResBody.response) {
                                twiml.sms('No results for that song were found :(');
                                res.end(twiml.toString());
                            } else{
                                if(echonestResBody.response.songs.length === 0 || !'tracks' in echonestResBody.response.songs[0] || echonestResBody.response.songs[0].tracks.length === 0) {
                                    twiml.sms('Looks like that song isn\'t available on Spotify :(');
                                    res.end(twiml.toString());
                                } else{
                                    if(echonestResBody.response.songs[0].tracks[0] == undefined) {
                                        twiml.sms('Looks like that artist isn\'t available on Spotify :(');
                                        res.end(twiml.toString());
                                    } else{
                                        var song = echonestResBody.response.songs[0];
                                        twiml.sms('Adding \'' + song.title + '\' to the queue!');
                                        
                                        var spotifyUrl = echonestResBody.response.songs[0].tracks[0].foreign_id;
                                        spotifyUrl = spotifyUrl.split(':')[0].split('-')[0] + ':' + spotifyUrl.split(':').slice(1).join(':');

                                        var echonestId = echonestResBody.response.songs[0].id;
                                        var requestOptions = {
                                            host: echonestUrl,
                                            port: 80,
                                            path: echonestTrackProfilePath + qs.stringify({api_key: echonestApiKey, id: echonestId, bucket: 'audio_summary'}),
                                            method: 'GET'
                                        };
                                        var audioSummaryRequest = http.request(requestOptions, function(echonestRes) {
                                            var echonestResBody = '';
                                            echonestRes.on('data', function(chunk) {
                                                echonestResBody += chunk;
                                            });
                                            echonestRes.on('end', function() {
                                                echonestResBody = JSON.parse(echonestResBody);
                                                if(!'track' in echonestResBody) {
                                                    twiml.sms('There was an error :(');
                                                } else{
                                                    var audioSummary = echonestResBody.response.songs[0].audio_summary;
                                                    currentPlayerConnection.write(JSON.stringify({command: 'queueTrack', url: spotifyUrl, summary: audioSummary, sender: senderUserName}) + '\n');
                                                }
                                            });
                                            res.end(twiml.toString());            
                                        }).end();
                                    }
                                }   
                            }
                            res.end(twiml.toString());
                        });
                     }).end();
    			}
                break;
    		}
            case 'pause' : {
                console.log(senderUserName);
                if(senderUserName === 'matt') {
                    console.log('pausing');
                    currentPlayerConnection.write(JSON.stringify({command: 'pause', sender: senderUserName}) + '\n');
                    res.end();
                }
                break;
            }
            case 'play' : {
                if(senderUserName === 'matt') {
                    currentPlayerConnection.write(JSON.stringify({command: 'play', sender: senderUserName}) + '\n');
                    res.end();
                }
                break;
            }
            case 'skip' : {
                if(senderUserName === 'matt') {
                    currentPlayerConnection.write(JSON.stringify({command: 'skip', sender: senderUserName}) + '\n');
                    res.end();
                }
                break;
            }
    	}
    });

    res.writeHead(200, {'Content-Type' : 'text/xml'});
});

twilioServer.listen(1337);

var spotifyPlayerServer = net.createServer(function(c) {
	console.log('got a player connection');

	currentPlayerConnection = c;

    c.on('end', function() {
        currentPlayerConnection == -1;
    })
});

process.on('uncaughtException', function() {
    console.log('something isn\'t right, server in an unstable state');
})

spotifyPlayerServer.listen(1338);

console.log('TwiML server running at 127.0.0.1:1337');

