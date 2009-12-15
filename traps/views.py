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
from django.db.models import Count
from django.core.exceptions import ObjectDoesNotExist
import urbanairship


#def tb(f):
	#def new_f():
		#print "entering ", f.__name__
		#try:
			#f()
		#except Exception as e:
			#print type(e)
			#print e
			#print sys.exc_info()[0]
		#print "exiting ", f.__name__
	#return new_f

class TooManySearchResultsError(Exception):
	def __init__(self, value):
		self.value = value
	def __str__(self):
		return repr(self.value)	

def findYelpVenues(lat, lon):

	#If we are online
	try:
		api_url = 'http://api.yelp.com/business_review_search?term=yelp&lat='+lat+'&long='+lon+'&radius=.1&num_biz_requested=10&ywsid='+ config.yelp_api_key
		json_returned = simplejson.load(urllib.urlopen(api_url))

		#foursquare_api_url = 'http://api.foursquare.com/venues?geolat=%s&geolong=%s' %(lat, lon)
		#foursquare_json_returned = simplejson.load(urllib.urlopen(foursquare_api_url))

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
					pass
					
	except TooManySearchResultsError: 
		#print "Too Many"
		raise TooManySearchResultsError(e.value)
	
	return dbBusinessList

def noTrapWasHere(uid, venue):

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
	#uid is the user who set off the trap
	alertNote = 'Someone just hit the trap you left at %s' % (venue.name)
	theTrapQuery = VenueItem.objects.filter(venue__id__exact=venue.id).filter(dateTimeUsed__isnull=True)
	token = theTrapQuery[0].user.iphoneDeviceToken
	## From go.urbanairship.com. This is the App key and the APP MASTER SECRET...not the app secret
	airship = urbanairship.Airship('EK_BtrOrSOmo95TTsAb_Fw', 'vAixh-KLT5u0Ay8Xv6cf4Q')
	
	#TODO This needs to be deferred for sure
	#airship.push({'aps':{'alert':alertNote}}, aliases=['hollabills'])
	airship.push({'aps':{'alert':alertNote}, 'device_tokens':[token]})

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
	return {'traps':trapData, 'hitpointslost':totalDamage , 'hitpointsleft': user.hitPoints}

def getUserInventory(uid):
	#>>> roditems = user.useritem_set.all()
	traps = TrapsUser.objects.get(id=uid).useritem_set.all()
	
	try:
		#annotated_inv = TrapsUser.objects.get(id=1).useritem_set.all().values('item').annotate(Count('item')).order_by()
		annotated_inv = traps.values('item').annotate(Count('item')).order_by()
	except:
		#print sys.exc_info()[0]
		#print type(inst)
		#print inst
		raise
		
	inventory = [{'name':Item.objects.get(id=i['item']).name, 'id':Item.objects.get(id=i['item']).id, 'count':i['item__count']} for i in annotated_inv]
	return inventory

def getUserProfile(uid):
	user = TrapsUser.objects.get(id=uid)
	inventory = getUserInventory(uid)
	#inventory = user.useritem_set.all()
	userInfo = {'twitterid':user.twitterid, 'photo':user.photo, 'gender':user.gender, 'coinCount':user.coinCount, 'hitPoints':user.hitPoints, 'level':user.level, 'killCount':user.killCount, 'trapsSetCount':user.trapsSetCount, 'username':user.user.username, 'inventory':inventory}
	return userInfo
	
#def SetTrap(request, vid, iid, uid):
def SetTrap(request):
	print "SetTrap"
	request.user.userprofile = get_or_create_profile(request.user)
	uid = request.user.userprofile.id
	vid = request.POST['vid']
	iid = request.POST['iid']
	iphonetoken = request.POST['deviceToken']
	
	venue = Venue.objects.get(foursquareid=vid)
	user = TrapsUser.objects.get(id=uid)
	user.iphoneDeviceToken = iphonetoken
	user.save()
	
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
		pass
		print "user has no items"
	
	ret = {}
	request.user.userprofile = get_or_create_profile(request.user)
	request.user.userprofile.event_set.create(type='ST')
	userInfo = getUserProfile(uid)
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

def giveItemsAtVenueToUser(user, nonTrapVenueItems):
	#Must do one of each type of rare item
	for nonTrap in nonTrapVenueItems:
		#nonTrap.count -= 1
		nonTrap.save()

		#TODO Revisit this idea here. No more count for UserItemo	Keep in mind that there IS a count at the VenueItem level
		#try:
			#item = user.useritem_set.get(item=nonTrap.item)
		#except:
			#item = user.useritem_set.create(item=nonTrap.item)	
		item = user.useritem_set.create(item=nonTrap.item)	
		#item.count += 1
		#item.save()

#@tb
def SearchVenue(request, vid=None):
	print "In Search Venue"
	print request.POST
	print vid
	if vid == None:
		vid = request.POST['vid']
	print vid
	
	request.user.userprofile = get_or_create_profile(request.user)
	request.user.userprofile.event_set.create(type='SE')
	print 1
	uid = request.user.userprofile.id
	print 2
	thisUsersTraps = request.user.userprofile.useritem_set.filter(item__type='TP')
	ret = {}
	if thisUsersTraps.count() != 0:
		print 3
		optionString = "You have %d traps. Would you like to set one?" %(thisUsersTraps.count())
		ret['hasTraps'] = True 
	else:
		print 31
		ret['hasTraps'] = False 
		optionString = "You have no traps"

	print 4
	venueSearch = Venue.objects.filter(foursquareid=vid)
	if len(venueSearch) == 0:
		print 5
		#this venue isn't in the db, create it
		a = urllib.urlopen("http://api.foursquare.com/v1/venue.json?vid="+vid)
		print 6
		json_str = a.read()
		print 7
		b = simplejson.loads(json_str)['venue']
		print 8
		v = Venue(foursquareid=vid, name=b['name'], 
					latitude=b['geolat'], longitude=b['geolong'], 
					streetName=b['address'], city=b['city'], state=b['state'], 
					coinValue=config.startVenueWithCoins)
		print 9
		v.save()
		print 10

	venue = Venue.objects.get(foursquareid=vid)
	itemsAtVenue = venue.venueitem_set.filter()
	itemsThatAreTraps = [i for i in itemsAtVenue if i.item.type =='TP' and i.dateTimeUsed==None]
	
	alertStatement = ''
	if len(itemsThatAreTraps) > 0:
		#There are traps, take action	
		ret['isTrapSet'] = True
		#request.user.userprofile = get_or_create_profile(request.user)
		request.user.userprofile.event_set.create(type='HT')
		ret['damage'] = trapWasHere(uid, venue, itemsThatAreTraps)
		ret['alertStatement'] = "There are traps at this venue. You took %s damage. %s" % (str(ret['damage']['hitpointslost']), optionString)
	else:
		#There are traps, take action	
		#no traps here, give the go ahead to get coins and whatever
		ret['isTrapSet'] = False

		#request.user.userprofile = get_or_create_profile(request.user)
		request.user.userprofile.event_set.create(type='NT')

		if len(itemsThatAreTraps) < len(itemsAtVenue):
			nonTraps = [i for i in itemsAtVenue if i.item.type !='TP']

			#The assumption here is that if it is not a trap, I should get it
			giveItemsAtVenueToUser(request.user.userprofile, nonTraps)

		ret['reward'] = noTrapWasHere(uid, venue)
		ret['alertStatement'] = ""
		
		alertStatement = "There are no traps here. You got %s coins." % ret['reward']['coins'] 
		ret['alertStatement'] = alertStatement + " " +optionString

	ret['venueid'] = vid
	ret['userid'] = uid
	
	#ret['profile'] = request.user.userprofile.objectify()
	ret['profile'] = request.user.userprofile.objectify()
	ret['profile']['inventory'] = getUserInventory(uid)
	print ret
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')


def GetUserProfileFromProfile(userprofile):
	dir(userprofile)
	profile = userprofile.objectify()
	profile['inventory'] = getUserInventory(userprofile.id)
	return profile
	
def GetUserProfile(request):
	userprofile = get_or_create_profile(request.user)
	return GetUserProfile(request, userprofile.id)

def GetUserProfile(request, uid):
	userprofile = get_or_create_profile(request.user)
	profile = userprofile.objectify()
	profile['inventory'] = getUserInventory(uid)
	return HttpResponse(simplejson.dumps(profile), mimetype='application/json')

def GetUserDropHistory(request):
	userprofile = get_or_create_profile(request.user)
	#relevantHistoryItems = ['LI', 'PC', 'SE', 'UI', 'HT', 'ST']
	#history=userprofile.event_set.filter(type__in=relevantHistoryItems)	
	history=VenueItem.objects.filter(user__id__exact=userprofile.id)
	jsonHistory = [h.objectify() for h in history]
		
	return HttpResponse(simplejson.dumps(jsonHistory), mimetype='application/json')

def GetUserHistory(request):
	userprofile = get_or_create_profile(request.user)
	relevantHistoryItems = ['LI', 'PC', 'SE', 'UI', 'HT', 'ST']
	history=userprofile.event_set.filter(type__in=relevantHistoryItems)	
	jsonHistory = [h.objectify() for h in history]
		
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
	jsonprofile = {}
	profile=None

	#TODO error case and feed it back to the iphone
	#1. user name already exists does not work
	#just in case
	#logout(request)
	uname = request.POST['uname']
	password = request.POST['password']

	#profile = doLogin(request, uname, password)

	user = authenticate(username=uname, password=password)
	#user.userprofile = {}
	print user
	if user is not None:
		if user.is_active:
			login(request, user)
			user.userprofile = get_or_create_profile(user)
			user.userprofile.event_set.create(type='LI')
			profile = user.userprofile
			
		else:
			#return a disabled account error message
			pass
	else:
		profile = doLogin(request, uname, password)
		
		#return "invalid login error message
		pass

	jsonprofile = profile.objectify()

	return HttpResponse(simplejson.dumps(jsonprofile), mimetype='application/json')
	
#@tb
def Logout(request):
	logout(request)
	return HttpResponse({'status':'success'}, mimetype='application/json')
	#return HttpResponseRedirect('/loggedOut/')

def Login(request):
	uname = request.GET['uname']
	password = request.GET['email']

	profile = doLogin(request, uname, password)

	return HttpResponseRedirect('/startup/')
	
def doLogin(request, uname, password):
	
	if request.user.is_anonymous():
		print "In doLogin, user is anonymous"
		#create user and profile Create New User
		user = User.objects.create_user(uname, 'none', password)
		user = authenticate(username=uname, password=password)
		login(request, user)
		user.userprofile = get_or_create_profile(user)
		user.userprofile.event_set.create(type='LI')
		#create a whole bunch of bananas	
		for i in range(config.numStarterItems):
			starterItem = Item.objects.get(id=1)
			user.userprofile.useritem_set.create(item=starterItem)
	else:
		print "In doLogin, user is not"
		user = request.user	
		user.userprofile = get_or_create_profile(user)
		user.userprofile.event_set.create(type='LI')
	

	return user.userprofile
	
def FindNearby(request):

	try:
		ld = request.POST.get('ld', 0)
		if ld:
			lat, lon = ld[ld.find("<")+1:ld.find(">")].split(", ")
		else:
			#yelp address
			lat = '37.788022'
			lon = '-122.399797'

			#larkin street
		lat = "37.791846"
		lon = "-122.419388"

		#Find all venues near this one
		venues = Venue.objects.all()

		#Stored Venues
		sendable_venues = [{'name':v.name, 'phone':v.phone, 'longitude':v.longitude} for v in venues]
		ret = {'venues':sendable_venues}

		#find all yelp venues near here
		#new yelp venues
		dbVenues = findYelpVenues(lat, lon)
		json = [v[0].objectify() for v in dbVenues]
		#ret['businessList'] = dbVenues
		#return HttpResponse(simplejson.dumps({'x':json}), mimetype='application/json')
		request.user.userprofile = get_or_create_profile(request.user)
		request.user.userprofile.event_set.create(type='FN')
	except:
		print sys.exc_info()[0]


	return HttpResponse(simplejson.dumps(json), mimetype='application/json')

def SetDeviceToken(request):
	ret = {"rc":0}
	try:
		userprofile = get_or_create_profile(request.user)
		userprofile.iphoneDeviceToken = request.POST['deviceToken']
		userprofile.save()
		
	except:
		ret = {"rc":1}
		
	
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')
