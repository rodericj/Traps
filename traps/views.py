import urllib
import operator
import config
from datetime import datetime

#from traps import push

from Traps.traps.models import Venue, Item, TrapsUser, VenueItem, Event

from django.shortcuts import HttpResponse, HttpResponseRedirect, render_to_response, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.utils import simplejson
from django.contrib.auth.models import User
from django.db.models import Count
from django.core.exceptions import ObjectDoesNotExist



### IPhone views
def set_device_token(request):
	"""
	In order to do push notifications for the iphone we need to store the phone's device id.
	This takes the deviceToken and associates it with the user.
	"""
	ret = {"rc":0}
	try:
		user_profile = _get_or_create_profile(request.user)
		user_profile.iphoneDeviceToken = request.POST['deviceToken']
		user_profile.save()
		
	except:
		ret = {"rc":1}
		
	
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')


def iphone_login(request):
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

	user = authenticate(username=uname, password=password)
	if user is not None:
		if user.is_active:
			login(request, user)
			user.user_profile = _get_or_create_profile(user)
			user.user_profile.event_set.create(type='LI')
			profile = user.user_profile
			#TODO check and set???
			profile.user.first_name = first_name
			profile.user.last_name = last_name
			profile.user.save()
			
		else:
			#return a disabled account error message
			pass
	else:
		profile = _do_login(request, uname, password)
		
	if tutorial and profile.tutorial < 2:
		profile.tutorial = tutorial
		profile.save()
	jsonprofile = profile.objectify()
	jsonprofile['inventory'] = _get_user_inventory(profile.id)

	jsonprofile = _set_tutorial(profile.id, jsonprofile)
	return HttpResponse(simplejson.dumps(jsonprofile), mimetype='application/json')
	
#@tb
def app_logout(request):
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
	uname = request.POST['uname']
	password = request.POST['password']

	profile = _do_login(request, uname, password)

	ret = {}
	ret['profile'] = profile.objectify()
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')
	
def trapWasHere(user, venue, itemsThatAreTraps):
	"""
	The user has searched here and there was in fact a trap. Cause damage and most likely
	remove the trap that was at this venue
	"""
	totalDamage = 0
	trapData = [] 
	for trap in itemsThatAreTraps:
		#TODO v2 see if they have a shield
		#TODO v2 see if there was a multiplier on the trap
		totalDamage += trap.item.value
		trapData.append({'trapname':trap.item.name,'trapvalue':trap.item.value, 'trapperid':trap.user_id, 'trappername':trap.user.user.username})
		trap.dateTimeUsed = datetime.now() 
		trap.save()
	#user = TrapsUser.objects.get(id=uid)
	user.hitPoints = max(user.hitPoints - totalDamage, 0)
	user.save()
	return {'traps':trapData, 'hitpointslost':totalDamage , 'hitpointsleft': user.hitPoints}

def _get_user_inventory(uid):
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

	inventory = []
	for i in annotated_inv:
		item = Item.objects.get(id = i['item'])
		name = item.name
		id = item.id
		count = i['item__count']
		path = 'site_media/'+item.assetPath.split(config.MEDIA_DIRECTORY)[1]
		type = item.type
		note = item.note

		inventory.append({'name':name, 'id':id, 'count':count, 'path':path, 'type':type, 'note':note})

	return inventory

def getUserProfile(uid):
	user = TrapsUser.objects.get(id=uid)
	inventory = _get_user_inventory(uid)
	#inventory = user.useritem_set.all()
	userInfo = {'twitterid':user.twitterid, 'photo':user.photo, 'gender':user.gender, 'coinCount':user.coinCount, 'hitPoints':user.hitPoints, 'level':user.level, 'killCount':user.killCount, 'trapsSetCount':user.trapsSetCount, 'username':user.user.username, 'inventory':inventory}
	return userInfo
	
def set_trap(request):
	"""
	The action for the user setting the trap. 
	-Decreases the number of traps the user has 
	-adds the trap as a VenueItem
	-sets up the user for notifications
	"""
	request.user.user_profile = _get_or_create_profile(request.user)
	uid = request.user.user_profile.id
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
		armedTrap = user.useritem_set.get(id=alltraps[0].id)
		armedTrap.delete()
		#armedTrap.isHolding=False
		#armedTrap.save()
		#alltraps[0].delete()

	else:
		pass
	
	ret = {}
	request.user.user_profile = _get_or_create_profile(request.user)
	request.user.user_profile.event_set.create(type='ST', data1=venue.id)
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

		item = user.useritem_set.create(item=nonTrap.item)	
#@tb
def search_venue(request, vid=None):
	"""
	Searching a venue is the critical part of this entire game. 
	-Determines if there is a trap at this venue
	-tells the user what is here
	-gives coins, xp, items to the user
	"""
	if vid == None:
		vid = request.POST['vid']
	
	tutorial = request.POST.get('tutorial', 3)

	request.user.user_profile = _get_or_create_profile(request.user)


	uid = request.user.user_profile.id
	thisUsersTraps = request.user.user_profile.useritem_set.filter(item__type='TP')
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
	request.user.user_profile.event_set.create(type='SE', data1=venue.id)
	itemsAtVenue = venue.venueitem_set.filter()
	itemsThatAreTraps = [i for i in itemsAtVenue if i.item.type == 'TP' and i.dateTimeUsed == None]
	
	alertStatement = ''
	if len(itemsThatAreTraps) > 0:
		#There are traps, take action	
		ret['isTrapSet'] = True
		_notify_trap_setter(uid, venue)	
		ret['damage'] = trapWasHere(request.user.user_profile, venue, itemsThatAreTraps)
		ret['alertStatement'] = "There are traps at this venue. You took %s damage. %s" % (str(ret['damage']['hitpointslost']), optionString)
	else:
		#no traps here, give the go ahead to get coins and whatever
		ret['isTrapSet'] = False

		request.user.user_profile.event_set.create(type='NT', data1=venue.id)

		if len(itemsThatAreTraps) < len(itemsAtVenue):
			nonTraps = [i for i in itemsAtVenue if i.item.type != 'TP']

			#The assumption here is that if it is not a trap, I should get it
			giveItemsAtVenueToUser(request.user.user_profile, nonTraps)

		ret['reward'] = _no_trap_was_here(request.user.user_profile, venue)
		ret['alertStatement'] = ""
		
		alertStatement = "There are no traps here. You got %s coins." % ret['reward']['coins'] 
		ret['alertStatement'] = alertStatement + " " +optionString

	venue.checkinCount += 1;
	venue.save()
	ret['venueid'] = vid
	ret['userid'] = uid
	
	ret['profile'] = request.user.user_profile.objectify()
	ret['profile']['inventory'] = _get_user_inventory(uid)
	

	#if this user is in tutorial mode, we'll have to return a different result
	if int(tutorial) == 4:

		#If they hit a trap during the tutorial, I wanna make it up to them
		damage = ret.get('damage', {'hitpointslost':0})
		request.user.user_profile.hitPoints += damage['hitpointslost']

		#must give the guy the egg/newbie badge
		#golden_egg = Item.objects.get(id=config.golden_egg_iid)
		banana_trap = Item.objects.get(id=config.banana_iid)
		request.user.user_profile.useritem_set.create(item=banana_trap)

		#fabricate a return statement
		ret = {'alertStatement':config.tutorial3,
				'hasTraps':thisUsersTraps.count() != 0 and 1 or 2,
				'isTrapSet':0,
				'userid':request.user.id,
				'venueid':vid}
		ret['profile'] = request.user.user_profile.objectify()
		ret['profile']['inventory'] = _get_user_inventory(request.user.user_profile.id)
		request.user.user_profile.tutorial += 1
		request.user.user_profile.save()
		return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

@login_required
def show_all_traps_set(request):
	"""
	The admin view for showing all of the traps that are in the system.
	This will need a bit of work and MUST require you to login as an admin.
	"""
	items = VenueItem.objects.filter(dateTimeUsed__exact=None)
	VenueList = [i.objectify() for i in items]	
	return render_to_response('ShowAllTrapsSet.html', {'VenueList':items})

def get_friends(request):
	"""
	Given a list of facebook friends. Show the stats for each of these friends.
	Returns a json encoded array of friend dictionaries
	"""
	u = request.user
	#get the string argument
	#friendString = request.POST['friends']
	friendString = request.GET['friends']

	#convert the string to an array of dicts
	friendArray = simplejson.loads(str(friendString.encode('utf-8')))
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
	
def GetUserProfileFromProfile(user_profile):
	"""
	returns a users serialized profile with the inventory attached
	"""
	profile = user_profile.objectify()
	profile['inventory'] = _get_user_inventory(user_profile.id)
	return profile
	
def get_my_user_profile(request):
	"""
	Get's the logged in user's profile
	"""
	user_profile = _get_or_create_profile(request.user)
	response =  GetUserProfile(request, user_profile.id)
	return response

def DoesUserExist(request, uid):
	"""
	For the webapp, need to determine if the given user exists
	"""
	ret = {}
	try:
		User.objects.get(username=uid)
		ret['exists'] = True
	except:
		ret['exists'] = False
	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

def GetUserProfile(request, uid):
	"""
	Return the user's profile of the user with passed in uid
	"""
	user_profile = _get_or_create_profile(request.user)
	profile = user_profile.objectify()
	profile['inventory'] = _get_user_inventory(uid)
	return HttpResponse(simplejson.dumps(profile), mimetype='application/json')

def GetUserDropHistory(request):
	"""
	Returns all of the VenueItems that are associated with this user
	"""
	user_profile = _get_or_create_profile(request.user)
	#relevantHistoryItems = ['LI', 'PC', 'SE', 'UI', 'HT', 'ST']
	history = VenueItem.objects.filter(user__id__exact=user_profile.id)
	jsonHistory = [h.objectify() for h in history]
		
	return HttpResponse(simplejson.dumps(jsonHistory), mimetype='application/json')

def GetUserHistory(request):
	"""
	Returns the list of all of the events that have happened to or by this user
	"""
	user_profile = _get_or_create_profile(request.user)
	relevantHistoryItems = ['LI', 'PC', 'SE', 'UI', 'HT', 'ST']
	history = user_profile.event_set.filter(type__in=relevantHistoryItems)	
	jsonHistory = [h.objectify() for h in history]
		
	return HttpResponse(simplejson.dumps(jsonHistory), mimetype='application/json')

def GetVenue(request, vid):
	"""
	Returns the details of the venue described by the vid
	-This event is logged. Though may not be needed
	"""
	request.user.user_profile = _get_or_create_profile(request.user)
	request.user.user_profile.event_set.create(type='GV')
	venue = Venue.objects.get(id=vid)

	return HttpResponse(simplejson.dumps(venue.objectify()), mimetype='application/json')
def get_user_feed(request):
	"""
	Retrieving the user's activity feed
	"""
	userProfile = _get_or_create_profile(request.user)
	myActions = ['SE', 'ST', 'HT', 'FI', 'GC']
	othersActions = ['HT']
	events = Event.objects.filter(type__in=myActions, user__id__exact=userProfile.id) | Event.objects.filter(type__in=othersActions, data1__exact=userProfile.id)[:10]
	ret = [e.objectify() for e in events]
	ret.sort(lambda x,y:cmp(y['datetime'],x['datetime']))
	#ret = [i for i in ret if 
	#don't update, must do something else
	for i in ret:
		#TODO v2 Boooooo default to the first venue? Ghetto
		try:
			if len(i['data1']) > 0:	
				name = Venue.objects.get(id=i['data1']).name
			else:
				name = ""

		except:
			name = "id = "+i['data1']
		i['name'] = i['type'] + " " +name

	return HttpResponse(simplejson.dumps(ret), mimetype='application/json')

### Web app views
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



### Private methods

def _set_tutorial(user_id, json):
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

def _no_trap_was_here(user, venue):
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


def _notify_trap_setter(uid, venue):
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

	#setterPhone = push.iPhone()
	#setterPhone.udid = token
	#setterPhone.send_message(alertNote, sandbox=not config.PRODUCTION)
	
def _get_or_create_profile(user):
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

def _do_login(request, uname, password):
	"""
	The login function which actually executes the login with the password

	"""
	
	if request.user.is_anonymous():
		#create user and profile Create New User
		user = User.objects.create_user(uname, 'none', password)
		user = authenticate(username=uname, password=password)
		login(request, user)
		user.user_profile = _get_or_create_profile(user)
		user.user_profile.event_set.create(type='LI')

		last_name = request.POST.get('last_name', '')
		first_name = request.POST.get('first_name', '')

		user.first_name = first_name
		user.last_name = last_name
		user.save()
		#create a whole bunch of bananas	
		for i in range(config.numStarterItems):
			starterItem = Item.objects.get(id=1)
			user.user_profile.useritem_set.create(item=starterItem)
	else:
		user = request.user	
		user.user_profile = _get_or_create_profile(user)
		user.user_profile.event_set.create(type='LI')
	
	return user.user_profile
	
