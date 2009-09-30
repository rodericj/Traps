from django.shortcuts import HttpResponse
from Traps.traps.models import Venue
import urllib
import sys
import config
import test
from django.utils import simplejson

class TooManySearchResultsError(Exception):
	def __init__(self, value):
		self.value = value
	def __str__(self):
		return repr(self.value)	

# Create your views here.
def findYelpVenues(lat, lon):

	#If we are online
	try:
		api_url = 'http://api.yelp.com/business_review_search?term=yelp&lat='+lat+'&long='+lon+'&radius=.1&num_biz_requested=10&ywsid='+ config.yelp_api_key
		json_returned = simplejson.load(urllib.urlopen(api_url))
		#print json_returned
		businessList = json_returned['businesses'] 
		dbBusinessList = []
		for business in businessList: 
			dbsearch = Venue.objects.filter(yelpAddress=business['url'])
			if len(dbsearch) > 1:
				raise TooManySearchResultsError("Too many search results")
			if dbsearch:
				print "it exists"
				dbBusinessList.append(dbsearch[0])
			else:
				print "it doesn't exist"
				#create this venue
				business['reviews'] = ''
				b = business
				try:
					v = Venue(name=b['name'], latitude=b['latitude'], longitude=b['longitude'], yelpAddress=b['url'], streetName=b['address1'], city=b['city'], state=b['state'], coinValue=config.startVenueWithCoins, phone=b['phone'])
					v.save()
					dbBusinessList.append(v)
				except:
					print b['name'] + " will not be added"
					
	except TooManySearchResultsError: 
		print "Too Many"
		raise TooManySearchResultsError(e.value)
	#except:
		#print sys.exc_info()[0]
		#If we are not online basically, use the test data (TODO)
		#print "TESTING PHASE: COULD NOT CONNECT TO YELP"
		#businessList = simplejson.JSONDecoder.decode(test.yelp_json_venue_list)
		#print type(businessList)
	
	return dbBusinessList

def noTrapWasHere(uid, venue):
	print "get all the coins at this spot"
	reward = {'coins': venue.coinValue}
	user = User.objects.filter(id=uid)[0]
	user.coinCount += venue.coinValue
	user.save()
	reward['usersCoinTotal'] = user.coinCount

	print "get all rewards at this spot"
	itemsAtVenue = venue.item.values()
	#TODO figure out how to handle transferring items to users
	print "do something with the items "
	
	return reward

def trapWasHere(uid, venue, itemsThatAreTraps):
	totalDamage = 0
	for trap in itemsThatAreTraps:
		#TODO see if they have a sheild
		#TODO see if there was a multiplier on the trap
		totalDamage += trap.value
	user = User.objects.filter(id=uid)[0]
	user.hitpoints = max(user.hitpoints - totalDamage, 0)
	user.save()
	return {'hitpointslost':totalDamage , 'hitpointsleft': user.hitpoints}

def SearchVenue(request, vid):
	uid = request.user.id
	ret = {}
	venue = Venue.objects.filter(id=vid)[0]
	itemsAtVenue = venue.item.values()
	itemsThatAreTraps = [i for i in itemsAtVenue if i['type'] =='TP']
	
	if len(itemsThatAreTraps) > 0:
		#There are traps, take action	
		print "There are traps"
		ret['isTrapSet'] = True
		ret['damage'] = trapWasHere(uid, venue, itemsThatAreTraps)
	else:
		#no traps here, give the go ahead to get coins and whatever
		print "There are no traps"
		ret['isTrapSet'] = False
		ret['reward'] = noTrapWasHere(uid, venue)

	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')


def GetVenue(request, vid):
	print vid
	venue = Venue.objects.filter(id=vid)
	print venue[0].json()
	return HttpResponse(simplejson.dumps(venue[0].json()), mimetype='application/json')
	#VenuesO
def FindNearby(request):
	#Find all venues near this one
	venues = Venue.objects.all()

	#Stored Venues
	sendable_venues = [{'name':v.name, 'phone':v.phone, 'longitude':v.longitude} for v in venues]
	ret = {'venues':sendable_venues}

	#yelp address
	lat = '37.788022'
	lon = '-122.399797'

	#larkin street
	lat = "37.791846"
	lon = "-122.419388"

	#find all yelp venues near here
	#new yelp venues
	dbVenues = findYelpVenues(lat, lon)
	json = [v.json() for v in dbVenues]
	#ret['businessList'] = dbVenues
	#print ret.keys()
	#print ret['businessList'][0].json()
	#return HttpResponse(simplejson.dumps({'x':json}), mimetype='application/json')
	return HttpResponse(simplejson.dumps(json), mimetype='application/json')
