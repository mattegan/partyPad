##partyPad
formerly partyOutlook formerly danceParty

---

This is a hack I created for [music hack day NYC 2013](https://www.hackerleague.org/hackathons/music-hack-day-nyc-2013). It lets people text in songs they'd like to hear at a party, and an iPad queues them up, plays them, and then displays some quick stats about the party, with a stupid graph thing. It'll show how the tempo, 'energy' and 'danceability' of songs are changing throughout the party.

A node http server listens for requests from Twillio, pulls all sorts of data from the Echonest API and then hands an iPad app a Spotify resource identifier URI for the track, along with some information from the Echonest, and then the iPad app takes care of everything else, including playing tracks and displaying prettyful album art using CocoaLibSpotify.

Please don't look at this. Please don't look at this. This code is terrible, motivated by 12 hours at a standing desk from around midnight to noon with a brief napping stint on a hard carpet floor. No authentication, like, nothing, seriously, the way it figures out who is allowed to control playback (by texting 'skip,' 'pause,' or 'play') is by a hardcoded string (if you text 'name matt' congratulations, you're now the king of the party).

Anyway. I really like the concept. I'll be re-doing it, because I want to and stuff. I'd like to add some sort of stat counter and notification system, something like a list of who is playing the least dancable songs or something like that. Yay public shaming!

Anyway. Here's a pretty picture.

![](http://i.imgur.com/EFudpJI.png)

Lastly, I've removed my keys that libspotify requires from the appkey.c file, and I've also redacted my Echonest API keys. You're in luck because both of those things are like totally free (if you're paying for a Spotify premium account that is, so I totally lied actually).

Err, have fun and stuff.