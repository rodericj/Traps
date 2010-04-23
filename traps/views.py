from django.shortcuts import HttpResponse, HttpResponseRedirect, render_to_response, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from Traps.traps.models import Venue, Item, TrapsUser, VenueItem, Event
import urllib
import config
import operator
from datetime import datetime
from django.utils import simplejson
from django.contrib.auth.models import User
from django.db.models import Count
from django.core.exceptions import ObjectDoesNotExist
try:
	import urbanairship
except:
	pass

def setTutorial(user_id, json):
	""" 
	Setting the tutorial text for a user. This usually means they are moving to the next step
	"""
	u = TrapsUser.objects.get(id=user_id)
	if u.tutorial == 1:
		json['tutorialText'] = config.tutorial1
		json['tutorialValue'] = 1

	if u.tutorial == 2:
		json['tutorialText'] = config.tutorial2
		json['tutorialValue'] = 2

	if u.tutorial == 3:
		json['tutorialText'] = config.tutorial3
		json['tutorialValue'] = 3

	if u.tutorial == 4:
		json['tutorialText'] = config.tutorial4
		json['tutorialValue'] = 4
	return json

def noTrapWasHere(user, venue):
	"""
	The user has just searched this venue and found that there is no trap here. Perform actions as needed
	"""

	#potential coin reward - goes up 1 coin per minute to the max of that venue
	timeDelta = datetime.now() - venue.lastUpdated
	minutesSinceSearch = timeDelta.seconds/60
	calculatedRewardValue = min(venue.coinValue, minutesSinceSearch)
	reward = {'coins': calculatedRewardValue}

	if venue.checkinCount == 0:
		reward['coins'] = 3

	#user = TrapsUser.objects.get(id=uid)
	user.coinCount += calculatedRewardValue
	user.save()
	reward['usersCoinTotal'] = user.coinCount

	itemsAtVenue = venue.item.values()
	
	return reward

def GetUserFeed(request):
	"""
	Retrieving the user's activity feed
	"""
	userProfile = get_or_create_profile(request.user)
	myActions = ['SE', 'ST', 'HT', 'FI', 'GC']
	othersActions = ['HT']
	events = Event.objects.filter(type__in=myActions, user__id__exact=userProfile.id) | Event.objects.filter(type__in=othersActions, data1__exact=userProfile.id)[:10]
	ret = [e.objectify() for e in events]
	ret.sort(lambda x,y:cmp(y['datetime'],x['datetime']))
	#ret = [i for i in ret if 
	#don't update, must do something else
	for i in ret:
		#TODO Boooooo default to the first venue? Ghetto
		if len(i['data1']) > 0:	
			name = Venue.objects.get(id=i['data1']).name
		else:
			name = ""
		i['name'] = i['type'] + " " +name

	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

def notifyTrapSetter(uid, venue):
	"""
	Use whatever methods we have to contact the user who set this trap.
	Push notifications, activity feed stuff, email, etc
	"""
	alertNote = 'Someone just hit the trap you left at %s' % (venue.name)
	theTrapQuery = VenueItem.objects.filter(venue__id__exact=venue.id).filter(dateTimeUsed__isnull=True)
	trapSetter = theTrapQuery[0].user
	token = trapSetter.iphoneDeviceToken
	
	trapSetter.trapsSetCount -= 1

	trapSetter.killCount += 1
	trapSetter.save()
	trapSetter.event_set.create(type='HT', data1=uid)
	##TODO: configify this: From go.urbanairship.com. This is the App key and the APP MASTER SECRET...not the app secret

	#development urban airship values
	airship = urbanairship.Airship('EK_BtrOrSOmo95TTsAb_Fw', 'vAixh-KLT5u0Ay8Xv6cf4Q')

	#production urbain airship values
	#airship = urbanairship.Airship('VsK3ssUxRzCQJ6Rs_Sf7wg', 'c_JO0OFcSNKPFhyM-3Jq2A')

	#print "registering %s, %s" %(token, uid)
	try:
		airship.register(token)

		#TODO This needs to be deferred for sure
		airship.push({'aps':{'alert':alertNote}}, device_tokens=[token])
	#airship.push({'aps':{'alert':alertNote}, aliases=[uid])
	except:
        #I'm not going to wait around for airship to not fail
		#TODO send the exception so I know it's happening
		print "failed airship"
		pass
	

def trapWasHere(user, venue, itemsThatAreTraps):
	"""
	The user has searched here and there was in fact a trap. Cause damage and most likely
	remove the trap that was at this venue
	"""
	#notifyTrapSetter(uid, venue)	
	totalDamage = 0
	trapData = [] 
	for trap in itemsThatAreTraps:
		#TODO see if they have a sheild
		#TODO see if there was a multiplier on the trap
		totalDamage += trap.item.value
		trapData.append({'trapname':trap.item.name,'trapvalue':trap.item.value, 'trapperid':trap.user_id, 'trappername':trap.user.user.username})
		trap.dateTimeUsed = datetime.now() 
		trap.save()
	#user = TrapsUser.objects.get(id=uid)
	user.hitPoints = max(user.hitPoints - totalDamage, 0)
	user.save()
	return {'traps':trapData, 'hitpointslost':totalDamage , 'hitpointsleft': user.hitPoints}

def getUserInventory(uid):
	"""
	Retrieve all of the items in the users inventory in an annotated list format with all the relevant data:
    example of a user with 863 banana peels

        {
        count = 863;
        id = 1;
        name = "Banana Peel";
        note = "This is a banana peel. it will knock you over.";
        path = "site_media/images/banana.png";
        type = TP;
    }

	This is called at least 2x in the iphone client
	"""
	#>>> roditems = user.useritem_set.all()
	traps = TrapsUser.objects.get(id=uid).useritem_set.all()
	
	try:
		annotated_inv = traps.values('item').annotate(Count('item')).order_by()
	except:
		raise
		
	inventory = [{'name':Item.objects.get(id = i['item']).name, 'id':Item.objects.get(id = i['item']).id, 'count':i['item__count'], 'path':'site_media'+Item.objects.get(id=i['item']).assetPath.split('site_media/')[1], 'type':Item.objects.get(id = i['item']).type, 'note':Item.objects.get(id=i['item']).note} for i in annotated_inv]
	return inventory

def getUserProfile(uid):
	user = TrapsUser.objects.get(id=uid)
	inventory = getUserInventory(uid)
	#inventory = user.useritem_set.all()
	userInfo = {'twitterid':user.twitterid, 'photo':user.photo, 'gender':user.gender, 'coinCount':user.coinCount, 'hitPoints':user.hitPoints, 'level':user.level, 'killCount':user.killCount, 'trapsSetCount':user.trapsSetCount, 'username':user.user.username, 'inventory':inventory}
	return userInfo
	
#def SetTrap(request, vid, iid, uid):
def SetTrap(request):
	"""
	The action for the user setting the trap. 
	-Decreases the number of traps the user has 
	-adds the trap as a VenueItem
	-sets up the user for notifications
	"""
	request.user.userprofile = get_or_create_profile(request.user)
	uid = request.user.userprofile.id
	vid = request.POST['vid']
	iid = request.POST['iid']
	iphonetoken = request.POST['deviceToken']
	
	venue = Venue.objects.get(foursquareid=vid)
	user = TrapsUser.objects.get(id=uid)
	user.iphoneDeviceToken = iphonetoken
	user.trapsSetCount += 1;
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
	
	ret = {}
	request.user.userprofile = get_or_create_profile(request.user)
	request.user.userprofile.event_set.create(type='ST', data1=venue.id)
	#ret = getUserProfile(uid)
	user = TrapsUser.objects.get(id=uid)
	ret['profile'] = user.objectify()
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

def giveItemsAtVenueToUser(user, nonTrapVenueItems):
	"""
	When a user searches at an item, they pick up the things that were laying there.
	This is the mechanism which transfers the VenueItem to a UserItem
	"""
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
	"""
	Searching a venue is the critical part of this entire game. 
	-Determines if there is a trap at this venue
	-tells the user what is here
	-gives coins, xp, items to the user
	"""
	if vid == None:
		vid = request.POST['vid']
	
	tutorial = request.POST.get('tutorial', 3)

	request.user.userprofile = get_or_create_profile(request.user)


	uid = request.user.userprofile.id
	thisUsersTraps = request.user.userprofile.useritem_set.filter(item__type='TP')
	ret = {}
	if thisUsersTraps.count() != 0:
		optionString = "You have %d traps. Would you like to set one?" %(thisUsersTraps.count())
		ret['hasTraps'] = True 
	else:
		ret['hasTraps'] = False 
		optionString = "You have no traps"

	venueSearch = Venue.objects.filter(foursquareid=vid)
	if len(venueSearch) == 0:
		#this venue isn't in the db, create it
		a = urllib.urlopen("http://api.foursquare.com/v1/venue.json?vid="+vid)
		json_str = a.read()
		b = simplejson.loads(json_str)['venue']
		v = Venue(foursquareid=vid, name=b['name'], 
					latitude=b['geolat'], longitude=b['geolong'], 
					streetName=b['address'], city=b['city'], state=b['state'], 
					coinValue=config.startVenueWithCoins)
		v.save()

	venue = Venue.objects.get(foursquareid=vid)
	request.user.userprofile.event_set.create(type='SE', data1=venue.id)
	itemsAtVenue = venue.venueitem_set.filter()
	itemsThatAreTraps = [i for i in itemsAtVenue if i.item.type == 'TP' and i.dateTimeUsed == None]
	
	alertStatement = ''
	if len(itemsThatAreTraps) > 0:
		#There are traps, take action	
		ret['isTrapSet'] = True
		#request.user.userprofile = get_or_create_profile(request.user)
		notifyTrapSetter(uid, venue)	
		ret['damage'] = trapWasHere(request.user.userprofile, venue, itemsThatAreTraps)
		ret['alertStatement'] = "There are traps at this venue. You took %s damage. %s" % (str(ret['damage']['hitpointslost']), optionString)
	else:
		#no traps here, give the go ahead to get coins and whatever
		ret['isTrapSet'] = False

		#request.user.userprofile = get_or_create_profile(request.user)
		request.user.userprofile.event_set.create(type='NT', data1=venue.id)

		if len(itemsThatAreTraps) < len(itemsAtVenue):
			nonTraps = [i for i in itemsAtVenue if i.item.type != 'TP']

			#The assumption here is that if it is not a trap, I should get it
			giveItemsAtVenueToUser(request.user.userprofile, nonTraps)

		ret['reward'] = noTrapWasHere(request.user.userprofile, venue)
		ret['alertStatement'] = ""
		
		alertStatement = "There are no traps here. You got %s coins." % ret['reward']['coins'] 
		ret['alertStatement'] = alertStatement + " " +optionString

	venue.checkinCount += 1;
	venue.save()
	ret['venueid'] = vid
	ret['userid'] = uid
	
	#ret['profile'] = request.user.userprofile.objectify()
	ret['profile'] = request.user.userprofile.objectify()
	ret['profile']['inventory'] = getUserInventory(uid)
	

	#if this user is in tutorial mode, we'll have to return a different result
	#if tutorial and request.user.userprofile.tutorial == 2:
	if int(tutorial) == 4:

		#If they hit a trap during the tutorial, I wanna make it up to them
		damage = ret.get('damage', {'hitpointslost':0})
		request.user.userprofile.hitPoints += damage['hitpointslost']

		#must give the guy the egg/newbie badge
		#golden_egg = Item.objects.get(id=config.golden_egg_iid)
		banana_trap = Item.objects.get(id=config.banana_iid)
		#request.user.userprofile.useritem_set.create(item=golden_egg)
		request.user.userprofile.useritem_set.create(item=banana_trap)

		#fabricate a return statement
		ret = {'alertStatement':config.tutorial3,
				'hasTraps':thisUsersTraps.count() != 0 and 1 or 2,
				'isTrapSet':0,
				'userid':request.user.id,
				'venueid':vid}
		ret['profile'] = request.user.userprofile.objectify()
		ret['profile']['inventory'] = getUserInventory(request.user.userprofile.id)
		request.user.userprofile.tutorial += 1
		request.user.userprofile.save()
		return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

def ShowAllTrapsSet(request):
	"""
	The admin view for showing all of the traps that are in the system.
	This will need a bit of work and MUST require you to login as an admin.
	"""
	#TODO Must require login. Must lock this view down

	#items = VenueItem.objects.all()
	items = VenueItem.objects.filter(dateTimeUsed__exact=None)
	VenueList = [i.objectify() for i in items]	
	return render_to_response('ShowAllTrapsSet.html', {'VenueList':items})

def GetFriends(request):
	"""
	Given a list of facebook friends. Show the stats for each of these friends.
	Returns a json encoded array of friend dictionaries
	"""
	u = request.user
	#get the string argument
	#friendString = request.POST['friends']
	friendString = request.GET['friends']

	#convert the string to an array of dicts
	friendArray = simplejson.loads(str(friendString))
	friendArray[0]['is_self']=True

	#get a list of the friend ids
	friendIds = [int(friend['uid']) for friend in friendArray]
	friendsHere = TrapsUser.objects.filter(user__username__in=friendIds)

	#make a mapping of fbids to kill count
	idKcMap = dict([(str(trapuser.user.username),trapuser.killCount) for trapuser in friendsHere])
	
	for i in friendArray:
		i['killCount'] = idKcMap.get(i['uid'], 0)
	
	#sort by kill count
	friendArray.sort(lambda x,y:cmp(y['killCount'],x['killCount']))
	return HttpResponse(simplejson.dumps(friendArray), mimetype='application/json')
	
def GetUserProfileFromProfile(userprofile):
	"""
	returns a users serialized profile with the inventory attached
	"""
	dir(userprofile)
	profile = userprofile.objectify()
	profile['inventory'] = getUserInventory(userprofile.id)
	return profile
	
def GetMyUserProfile(request):
	"""
	Get's the logged in user's profile
	"""
	userprofile = get_or_create_profile(request.user)
	return GetUserProfile(request, userprofile.id)

def GetUserProfile(request, uid):
	"""
	Return the user's profile of the user with passed in uid
	"""
	userprofile = get_or_create_profile(request.user)
	profile = userprofile.objectify()
	profile['inventory'] = getUserInventory(uid)
	return HttpResponse(simplejson.dumps(profile), mimetype='application/json')

def GetUserDropHistory(request):
	"""
	Returns all of the VenueItems that are associated with this user
	"""
	userprofile = get_or_create_profile(request.user)
	#relevantHistoryItems = ['LI', 'PC', 'SE', 'UI', 'HT', 'ST']
	#history=userprofile.event_set.filter(type__in=relevantHistoryItems)	
	history = VenueItem.objects.filter(user__id__exact=userprofile.id)
	jsonHistory = [h.objectify() for h in history]
		
	return HttpResponse(simplejson.dumps(jsonHistory), mimetype='application/json')

def GetUserHistory(request):
	"""
	Returns the list of all of the events that have happened to or by this user
	"""
	userprofile = get_or_create_profile(request.user)
	relevantHistoryItems = ['LI', 'PC', 'SE', 'UI', 'HT', 'ST']
	history = userprofile.event_set.filter(type__in=relevantHistoryItems)	
	jsonHistory = [h.objectify() for h in history]
		
	return HttpResponse(simplejson.dumps(jsonHistory), mimetype='application/json')

def GetVenue(request, vid):
	"""
	Returns the details of the venue described by the vid
	-This event is logged. Though may not be needed
	"""
	request.user.userprofile = get_or_create_profile(request.user)
	request.user.userprofile.event_set.create(type='GV')
	venue = Venue.objects.get(id=vid)

	return HttpResponse(simplejson.dumps(venue.objectify()), mimetype='application/json')

def get_or_create_profile(user):
	"""
	Determines if we actually need to create a user based on what is passed in from the netz
	If we do NOT have a user's (trpas) profile associated with this user, then create one
	else, return the profile that is attached to this (django) user
	"""
	try:
		profile = user.get_profile()
	except ObjectDoesNotExist:
		profile = TrapsUser(user=user)
		profile.save()
	return profile

def IPhoneLogin(request):
	"""
	Called from the iPhone when the home view is loaded. 
	-This checks to see if the user is currently logged in
	-May actually be a bit redundant
	"""
	jsonprofile = {}
	profile = None
	#TODO error case and feed it back to the iphone
	#1. user name already exists does not work
	#just in case
	#logout(request)
	uname = request.POST['uname']
	password = request.POST['password']
	first_name = request.POST.get('first_name', '')
	last_name = request.POST.get('last_name', '')
	tutorial = request.POST.get('tutorial', None)

	#profile = doLogin(request, uname, password)
	user = authenticate(username=uname, password=password)
	#user.userprofile = {}
	if user is not None:
		if user.is_active:
			login(request, user)
			user.userprofile = get_or_create_profile(user)
			user.userprofile.event_set.create(type='LI')
			profile = user.userprofile
			#TODO check and set???
			profile.user.first_name = first_name
			profile.user.last_name = last_name
			profile.user.save()
			
		else:
			#return a disabled account error message
			pass
	else:
		profile = doLogin(request, uname, password)
		
	if tutorial and profile.tutorial < 2:
		profile.tutorial = tutorial
		profile.save()
	jsonprofile = profile.objectify()
	jsonprofile['inventory'] = getUserInventory(profile.id)

	jsonprofile = setTutorial(profile.id, jsonprofile)
	return HttpResponse(simplejson.dumps(jsonprofile), mimetype='application/json')
	
#@tb
def Logout(request):
	"""
	Log the user out. May need to verify that this happens appropriately so the client knows 
	"""
	logout(request)
	return HttpResponse({'status':'success'}, mimetype='application/json')
	#return HttpResponseRedirect('/loggedOut/')

def Login(request):
	"""
	View for a web based login. This was a pre pre pre alpha view and may need to be deprecated
	"""
	uname = request.GET['uname']
	password = request.GET['email']

	profile = doLogin(request, uname, password)

	return HttpResponseRedirect('/startup/')
	
def doLogin(request, uname, password):
	"""
	The login function which actually executes the login with the password

	"""
	
	if request.user.is_anonymous():
		#create user and profile Create New User
		user = User.objects.create_user(uname, 'none', password)
		user = authenticate(username=uname, password=password)
		login(request, user)
		user.userprofile = get_or_create_profile(user)
		user.userprofile.event_set.create(type='LI')

		last_name = request.POST.get('last_name', '')
		first_name = request.POST.get('first_name', '')

		user.first_name = first_name
		user.last_name = last_name
		user.save()
		#create a whole bunch of bananas	
		for i in range(config.numStarterItems):
			starterItem = Item.objects.get(id=1)
			user.userprofile.useritem_set.create(item=starterItem)
	else:
		user = request.user	
		user.userprofile = get_or_create_profile(user)
		user.userprofile.event_set.create(type='LI')
	
	return user.userprofile
	
def SetDeviceToken(request):
	"""
	In order to do push notifications for the iphone we need to store the phone's device id.
	This takes the deviceToken and associates it with the user.
	"""
	ret = {"rc":0}
	try:
		userprofile = get_or_create_profile(request.user)
		userprofile.iphoneDeviceToken = request.POST['deviceToken']
		userprofile.save()
		
	except:
		ret = {"rc":1}
		
	
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

def holding(request):
	"""
	The front page for the project. Originally designed for people to go and find out about the product.
	Ultimately this will be the login page for new and existing users
	"""
	return render_to_response('holding_page.html')

def home_page(request):
	"""
	Show us the traps that have been set off
	"""
	objs = VenueItem.objects.order_by('-dateTimeUsed')[:15]
	recent = google_maps_items([(x.venue.latitude, x.venue.longitude) for x in objs])
	return render_to_response('homepage.html',{'recent' : recent, 'recent_items' : objs})

def google_maps_items(events):
	"""
	Something Peter put in. No internet at this place, so I can't see what it is. 
	Maybe he is up to no good.
	"""
	out = []
	out.append("icon:http://imgur.com/BRyp5.png")
	for e in events:
		out.append("%s,%s" % e )	
	return "|".join(out)
	
def qr_code(request, code):
	"""
	QR Codes.....You bastard!!!
	"""
	return render_to_response("qr_code.html")

def venue(request, eid):
	v = get_object_or_404(Venue, pk=eid)
	return render_to_response('venue.html', {'venue' : v})		
