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

	print "Find yelp ", (lat, lon)
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

#def SearchVenue(request):
	#print "In new search venue"
	
def SearchVenue(request, vid=None):
	if vid == None:
		print "vid is none"
		print request.POST
		vid = request.POST['vid'][0]
	
	print "1"
	request.user.userprofile = get_or_create_profile(request.user)
	print "2"
	request.user.userprofile.event_set.create(type='SE')
	print "3"
	uid = request.user.userprofile.id
	print "4"
	thisUsersTraps = request.user.userprofile.useritem_set.filter(item__type='TP')
	optionString = thisUsersTraps.count() != 0 and "You have traps. Would you like to set one?" or "You have no traps."
	print optionString
	ret = {}
	print "5"
	venue = Venue.objects.get(id=vid)
	print "6"
	itemsAtVenue = venue.venueitem_set.filter()
	print "7"
	itemsThatAreTraps = [i for i in itemsAtVenue if i.item.type =='TP' and i.dateTimeUsed==None]
	
	print "8"
	alertStatement = ''
	if len(itemsThatAreTraps) > 0:
		#There are traps, take action	
		ret['isTrapSet'] = True
		#request.user.userprofile = get_or_create_profile(request.user)
		request.user.userprofile.event_set.create(type='HT')
		ret['damage'] = trapWasHere(uid, venue, itemsThatAreTraps)
		ret['alertStatment'] = "There are traps at this venue. You took %s damage. %s" % ret['damage'], optionString
		print ret
	else:
		print "9"

		#no traps here, give the go ahead to get coins and whatever
		ret['isTrapSet'] = False
		#request.user.userprofile = get_or_create_profile(request.user)
		request.user.userprofile.event_set.create(type='NT')

		if len(itemsThatAreTraps) < len(itemsAtVenue):
			#nonTraps = [i for i in itemsAtVenue if i.count > 0 and i.item.type !='TP']
			nonTraps = [i for i in itemsAtVenue if i.item.type !='TP']
			#The assumption here is that if it is not a trap, I should get it
			giveItemsAtVenueToUser(request.user.userprofile, nonTraps)
		ret['reward'] = noTrapWasHere(uid, venue)
		ret['alertStatment'] = "There are no traps here. You got %s coins. %s" % ret['reward']['coins'], optionString
	print ret['alertStatment']

	ret['venueid'] = vid
	ret['userid'] = uid
	
	print ret
	print request.user.userprofile 
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

def IPhoneLogin(request):

	#TODO error case and feed it back to the iphone
    #1. user name already exists does not work
	#just in case
	logout(request)
	uname = request.POST['uname']
	password = request.POST['password']
	profile = doLogin(request, uname, password)
	jsonprofile = profile.objectify()
	print jsonprofile

	return HttpResponse(simplejson.dumps(jsonprofile), mimetype='application/json')
	
def Logout(request):
	logout(request)
	return HttpResponseRedirect('/loggedOut/')

def Login(request):
	print request.user
	uname = request.GET['uname']
	password = request.GET['email']

	profile = doLogin(request, uname, password)

	return HttpResponseRedirect('/startup/')
	
def doLogin(request, uname, password):

	if request.user.is_anonymous():
		#create user and profile Create New User
		print "create user"
		user = User.objects.create_user(uname, 'none', password)
		user = authenticate(username=uname, password=password)
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

	return user.userprofile
	
	
def FindNearby(request):
	print request.POST

	try:
		print "Finding Nearby Locations"
		ld = request.POST.get('ld', 0)
		if ld:
			print "Location description given"
			print ld
			lat, lon = ld[ld.find("<")+1:ld.find(">")].split(", ")
			print "Location description given done"
		else:
			print "default to yelp address"
			#yelp address
			lat = '37.788022'
			lon = '-122.399797'

			#larkin street
		print "Default to Larkin Street"
		lat = "37.791846"
		lon = "-122.419388"

		#Find all venues near this one
		venues = Venue.objects.all()
		print "Got ALL venues BAD---------"

		#Stored Venues
		sendable_venues = [{'name':v.name, 'phone':v.phone, 'longitude':v.longitude} for v in venues]
		ret = {'venues':sendable_venues}

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

	print "Got the json, from find Nearby. send it over"
	print json

	return HttpResponse(simplejson.dumps(json), mimetype='application/json')
