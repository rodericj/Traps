from django.db import models
import config
from django.contrib.auth.models import User

# Create your models here.
class Item(models.Model):
	TYPE_CHOICES = (
		#('PR', 'Permanent'),
		#('SP', 'Special'),
		#('TM', 'Temporary'),
		('RR', 'Rare'),
		('TP', 'Trap'),
		('DF', 'Defense'),
	)
	name = models.CharField(max_length=50)
	limit = models.IntegerField(default=0)
	note = models.CharField(max_length=100)
	timeToLive = models.IntegerField(default=0)
	assetPath = models.FilePathField(path="images")
	type = models.CharField(max_length=2, choices=TYPE_CHOICES)
	level = models.IntegerField(default=1)
	value = models.IntegerField(default=1)

	def __unicode__(self):
		return str(self.id) + " " + self.name

class Venue(models.Model):
	foursquareid = models.IntegerField(blank=False, null=False)
	name = models.CharField(max_length=50)
	latitude = models.FloatField()
	longitude = models.FloatField()
	#yelpAddress = models.CharField(max_length=100)
	streetName = models.CharField(max_length=100)
	city = models.CharField(max_length=30)
	state = models.CharField(max_length=30)
	zip = models.CharField(max_length=10)
	coinValue = models.IntegerField(default=config.startVenueWithCoins)
	phone = models.CharField(max_length=11)
	item = models.ManyToManyField(Item, blank=True, null=True)
	checkinCount = models.IntegerField(default=0)
	lastUpdated = models.DateTimeField(auto_now=True, auto_now_add=True)

	def objectify(self): 
		return {'id':self.id,
				 'name':self.name,
				 'latitude':str(self.latitude),
				 'longitude':str(self.longitude),
				 'streetName':self.streetName,
				 'city':self.city,
				 'state':self.state,
				 'coinValue':str(self.coinValue),
				 'phone':self.phone,
				 'checkinCount':str(self.checkinCount)
				}

	def __unicode__(self):
		#return "%d, %s" % (self.id, self.name)
		return "%s, id:%s" % (self.name, self.foursquareid)

#class ItemAtVenue(models.Model):
	#venue = models.ForeignKey(Venue)
	#item = models.ForeignKey(Item)

class TrapsUser(models.Model):
	GENDER_CHOICES = (
		('M', 'Male'),
		('F', 'Female')
	)
	#userName = models.CharField(max_length=20)
	#email = models.EmailField()
	fbid = models.IntegerField(null=True, blank=True)
	twitterid = models.CharField(max_length=15, null=True, blank=True)
	photo = models.FilePathField(path="images/avatars", null=True, blank=True)
	gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
	coinCount = models.IntegerField(default=config.startUserWithCoins)
	hitPoints = models.IntegerField(default=100)
	level = models.IntegerField(default=1)
	killCount = models.IntegerField(default=0)
	trapsSetCount = models.IntegerField(default=0)
	friends = models.ManyToManyField("self")
	user = models.ForeignKey(User, unique=True)
	lastUpdated = models.DateTimeField(auto_now=True, auto_now_add=True)
	iphoneDeviceToken = models.CharField(max_length=64, null=True, blank=True)
	tutorial = models.IntegerField(default=1)

	def objectify(self):
		return {
 				'coinCount':str(self.coinCount),
 				'hitPoints':str(self.hitPoints),
 				'killCount':str(self.killCount),
 				'trapsSetCount':str(self.trapsSetCount),
 				'username':self.user.username,
 				'lastUpdated':str(self.lastUpdated),
 				'level':str(self.level),
 				'iphoneDeviceToken':self.iphoneDeviceToken,
		}

	def __unicode__(self):
		u = self.user
		return "%d, %s, %s %s"% (self.id, u.username, u.first_name, u.last_name)

class Message(models.Model):
	#From #django:
	#User.message_set is conflicting with User.message_set. I want something similar to User.message_sender_set and User.message_receiver_set

	#mattmcc: roderic_: The value you give related_name is used to name the manager on the other model (User in this case) [9:52pm] mattmcc: So, given a user u, you'd have u.sent_messages.all()
	sender = models.ForeignKey(TrapsUser, related_name="sent_messages")
	reciever = models.ForeignKey(TrapsUser, related_name="received_messages")
	message = models.CharField(max_length=200)
	dateTime = models.DateTimeField(auto_now_add=True)
		
	def __unicode__(self):
		return self.sender + " to " + self.receiver + ": " + self.message

class Event(models.Model):
	EVENT_CHOICES = (
		('SE', 'Searched'),
		('GV', 'Get Venue'),
		('FN', 'Find Nearby Venues'),
		('ST', 'Set a Trap at'),
		('NT', 'No Trap'),
		('HT', 'Hit Trap'),
		('FI', 'Found Item'),
		('UI', 'Used Item'),
		('GC', 'Got Coins'),
		('PC', 'Purchase'),
		('LI', 'Log In'),
	)
	type = models.CharField(max_length=2, choices=EVENT_CHOICES)
	data1 = models.CharField(max_length=20)
	data2 = models.CharField(max_length=20)
	dateTime = models.DateTimeField(auto_now_add=True)
	user = models.ForeignKey(TrapsUser)

	def objectify(self): 
		return {'id':self.id,
				'type':dict(self.EVENT_CHOICES)[self.type],
				'data1':self.data1,
				'data2':self.data2,
				'datetime':str(self.dateTime)
				}

	def __unicode__(self):
		longtype = [i for i in self.EVENT_CHOICES if self.type in i][0][1]		
		ret =  str(self.user) + " "+longtype + " at " + str(self.dateTime) 
		if self.data1:
			ret += " data1 "+self.data1
		if self.data2:
			ret += " data2 "+self.data2

		return ret

class VenueItem(models.Model):
	venue = models.ForeignKey(Venue)
	item = models.ForeignKey(Item)	
	user = models.ForeignKey(TrapsUser, null=True, blank=True)
	#count = models.IntegerField(default=0)
	dateTimePlaced = models.DateTimeField(auto_now_add=True)
	dateTimeUsed = models.DateTimeField(null=True)
	
	
	def objectify(self): 
		return {'id':self.id, 
				'venuename':self.venue.name,
				'type':self.item.name, 
				'user':self.user.user.username, 
				'datetimeplaced':str(self.dateTimePlaced), 
				'datetimeused':str(self.dateTimeUsed)}

	def __unicode__(self):
		return str(self.venue) + " has a " + str(self.item)

class UserItem(models.Model):
	user = models.ForeignKey(TrapsUser)
	item = models.ForeignKey(Item)	
	isHolding = models.BooleanField(default=True)
	#count = models.IntegerField(default=0)

	def __unicode__(self):
		return str(self.user) + " " + str(self.item)
