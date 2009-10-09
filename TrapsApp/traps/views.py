from django.shortcuts import HttpResponse, HttpResponseRedirect
from django.contrib.auth import authenticate, login, logout
from Traps.traps.models import Venue, Item, TrapsUser, VenueItem
import urllib
import sys
import config
from datetime import datetime
import test
from django.utils import simplejson
from django.contrib.auth.models import User
from django.core.exceptions import ObjectDoesNotExist


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
				dbBusinessList.append(dbsearch)
			else:
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
	
	return dbBusinessList

def noTrapWasHere(uid, venue):
	print "get all the coins at this spot "+str(uid)+" " +str(venue)

	#potential coin reward - goes up 1 coin per minute to the max of that venue
	timeDelta = datetime.now()-venue.lastUpdated
	minutesSinceSearch = timeDelta.seconds/60
	calculatedRewardValue = min(venue.coinValue, minutesSinceSearch)
	reward = {'coins': calculatedRewardValue}

	user = TrapsUser.objects.get(id=uid)
	user.coinCount += calculatedRewardValue
	user.save()
	reward['usersCoinTotal'] = user.coinCount

	#Just to activate the "last save timestamp" so there are no coins for a bit
	if calculatedRewardValue:
		#only save if we gave away coins
		venue.save()
	itemsAtVenue = venue.item.values()
	
	return reward

def notifyTrapSetter(uid, venue):
	#TODO
	print "notify trap setter"

def trapWasHere(uid, venue, itemsThatAreTraps):
	notifyTrapSetter(uid, venue)	
	totalDamage = 0
	trapData = [] 
	for trap in itemsThatAreTraps:
		#TODO see if they have a sheild
		#TODO see if there was a multiplier on the trap
		totalDamage += trap.item.value
		trapData.append({'trapname':trap.item.name,'trapvalue':trap.item.value, 'trapperid':trap.user_id, 'trappername':trap.user.user.username})
		trap.dateTimeUsed = datetime.now() 
		trap.save()
	user = TrapsUser.objects.get(id=uid)
	user.hitPoints = max(user.hitPoints - totalDamage, 0)
	user.save()
	print "trapWasHere"
	print trapData
	return {'traps':trapData, 'hitpointslost':totalDamage , 'hitpointsleft': user.hitPoints}

def getUserProfile(isSelf, uid):
	user = TrapsUser.objects.get(id=uid)
	inventory = user.useritem_set.all()
	print inventory
	userInfo = {'twitterid':user.twitterid, 'photo':user.photo, 'gender':user.gender, 'coinCount':user.coinCount, 'hitPoints':user.hitPoints, 'level':user.level, 'killCount':user.killCount, 'trapsSetCount':user.trapsSetCount, 'username':user.user.username}
	return userInfo
	
def SetTrap(request, vid, iid, uid):
	venue = Venue.objects.get(id=vid)
	user = TrapsUser.objects.get(id=uid)

	#get the item from the user and subtract it
	alltraps = user.useritem_set.all()
	if len(alltraps) > 0:
		item = alltraps[0].item
		#put this item on the VenueItem table	
		venue.venueitem_set.create(item=item, user=user)
		#TODO I'm not defining WHICH trap I'm setting here
		#TODO actually this is kinda messy. I need to find only the holding traps
		armedTrap = user.useritem_set.get(id=alltraps[0].id)
		armedTrap.delete()
		#armedTrap.isHolding=False
		#armedTrap.save()
		#alltraps[0].delete()

	else:
		print "user has no items"
	
	ret = {}
	request.user.userprofile = get_or_create_profile(request.user)
	request.user.userprofile.event_set.create(type='ST')
	userInfo = getUserProfile(True, uid)
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

def giveItemsAtVenueToUser(user, nonTrapVenueItems):
	print "in give itmes at venue to user"
	#Must do one of each type of rare item
	for nonTrap in nonTrapVenueItems:
		print "picking up the %s" %(nonTrap.item.name)
		#nonTrap.count -= 1
		nonTrap.save()
		print nonTrap.item

		#TODO Revisit this idea here. No more count for UserItemo	Keep in mind that there IS a count at the VenueItem level
		#try:
			#item = user.useritem_set.get(item=nonTrap.item)
		#except:
			#item = user.useritem_set.create(item=nonTrap.item)	
		item = user.useritem_set.create(item=nonTrap.item)	
		#item.count += 1
		#item.save()

def SearchVenue(request, vid):
	request.user.userprofile = get_or_create_profile(request.user)
	request.user.userprofile.event_set.create(type='SE')
	uid = request.user.userprofile.id
	ret = {}
	venue = Venue.objects.get(id=vid)
	itemsAtVenue = venue.venueitem_set.filter()
	itemsThatAreTraps = [i for i in itemsAtVenue if i.item.type =='TP' and i.dateTimeUsed==None]
	
	if len(itemsThatAreTraps) > 0:
		#There are traps, take action	
		print "There are traps"
		ret['isTrapSet'] = True
		request.user.userprofile = get_or_create_profile(request.user)
		request.user.userprofile.event_set.create(type='HT')
		ret['damage'] = trapWasHere(uid, venue, itemsThatAreTraps)
		print "This is what we get when there are traps"
		print ret
	else:

		#no traps here, give the go ahead to get coins and whatever
		print "There are no traps"
		ret['isTrapSet'] = False
		request.user.userprofile = get_or_create_profile(request.user)
		request.user.userprofile.event_set.create(type='NT')

		if len(itemsThatAreTraps) < len(itemsAtVenue):
			#nonTraps = [i for i in itemsAtVenue if i.count > 0 and i.item.type !='TP']
			nonTraps = [i for i in itemsAtVenue if i.item.type !='TP']
			#The assumption here is that if it is not a trap, I should get it
			giveItemsAtVenueToUser(request.user.userprofile, nonTraps)
		ret['reward'] = noTrapWasHere(uid, venue)

	ret['venueid'] = vid
	ret['userid'] = uid
	print ret.keys()
	print ret
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')


def GetUserProfile(request):
	userprofile = get_or_create_profile(request.user)
	return GetUserProfile(request, userprofile.id)

def GetUserProfile(request, uid):
	userprofile = get_or_create_profile(request.user)
	profile = userprofile.objectify()
	print profile
	return HttpResponse(simplejson.dumps(profile), mimetype='application/json')

def GetUserDropHistory(request):
	userprofile = get_or_create_profile(request.user)
	print userprofile.id
	#relevantHistoryItems = ['LI', 'PC', 'SE', 'UI', 'HT', 'ST']
	#history=userprofile.event_set.filter(type__in=relevantHistoryItems)	
	history=VenueItem.objects.filter(user__id__exact=userprofile.id)
	jsonHistory = [h.objectify() for h in history]
	print "This is the items you have dropped"
	print jsonHistory
		
	return HttpResponse(simplejson.dumps(jsonHistory), mimetype='application/json')

def GetUserHistory(request):
	userprofile = get_or_create_profile(request.user)
	print userprofile.id
	relevantHistoryItems = ['LI', 'PC', 'SE', 'UI', 'HT', 'ST']
	history=userprofile.event_set.filter(type__in=relevantHistoryItems)	
	jsonHistory = [h.objectify() for h in history]
	print jsonHistory
		
	return HttpResponse(simplejson.dumps(jsonHistory), mimetype='application/json')

def GetVenue(request, vid):
	request.user.userprofile = get_or_create_profile(request.user)
	request.user.userprofile.event_set.create(type='GV')
	venue = Venue.objects.get(id=vid)

	return HttpResponse(simplejson.dumps(venue.objectify()), mimetype='application/json')

def get_or_create_profile(user):
	try:
		profile = user.get_profile()
	except ObjectDoesNotExist:
		profile = TrapsUser(user=user)
		profile.save()
	return profile

def Logout(request):
	logout(request)
	return HttpResponseRedirect('/loggedOut/')

def Login(request):
	print request.user
	uname = request.GET['uname']
	email = request.GET['email']

	if request.user.is_anonymous():
		#create user and profile Create New User
		print "create user"
		user = User.objects.create_user(uname, email, '123')
		user = authenticate(username=uname, password='123')
		login(request, user)
	else:
		user = request.user	
	
	user.userprofile = get_or_create_profile(user)
	user.userprofile.event_set.create(type='LI')
	print " created a new user %d" %(user.userprofile.id)
	
	#Is it safe to assume that a login is a first time user? I'm not sure TODO
	#create a whole bunch of bananas	
	
	for i in range(config.numStarterItems):
		starterItem = Item.objects.get(id=1)
		print starterItem
		user.userprofile.useritem_set.create(item=starterItem)
	
	return HttpResponseRedirect('/startup/')
	
def FindNearby(request):
	try:
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
		json = [v[0].objectify() for v in dbVenues]
		#ret['businessList'] = dbVenues
		#print ret.keys()
		#print ret['businessList'][0].json()
		#return HttpResponse(simplejson.dumps({'x':json}), mimetype='application/json')
		request.user.userprofile = get_or_create_profile(request.user)
		request.user.userprofile.event_set.create(type='FN')
	except:
		print sys.exc_info()[0]
		
	return HttpResponse(simplejson.dumps(json), mimetype='application/json')
