from django.db import models
import config
from django.contrib.auth.models import User

# Create your models here.
class Item(models.Model):
	TYPE_CHOICES = (
		('PR', 'Permanent'),
		('SP', 'Special'),
		('TM', 'Temporary'),
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
	name = models.CharField(max_length=50)
	latitude = models.FloatField()
	longitude = models.FloatField()
	yelpAddress = models.CharField(max_length=100)
	streetName = models.CharField(max_length=100)
	city = models.CharField(max_length=30)
	state = models.CharField(max_length=30)
	coinValue = models.IntegerField(default=config.startVenueWithCoins)
	phone = models.CharField(max_length=11)
	item = models.ManyToManyField(Item, blank=True, null=True)
	checkinCount = models.IntegerField(default=0)

	def json(self): 
		return {'id':self.id, 'name':self.name, 'latitude':self.latitude, 'longitude':self.longitude, 'streetName':self.streetName, 'city':self.city, 'state':self.state, 'coinValue':self.coinValue, 'phone':self.phone, 'checkinCount':self.checkinCount}

	def __unicode__(self):
		return self.name

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
	hitPoints = models.IntegerField(default=0)
	level = models.IntegerField(default=1)
	killCount = models.IntegerField(default=0)
	trapsSetCount = models.IntegerField(default=0)
	friends = models.ManyToManyField("self")
	#events = models.ManyToManyField(Event)
	user = models.ForeignKey(User, unique=True)

	def __unicode__(self):
		#return self.user.username+" coins: "+ str(self.coinCount) + " coins, " + str(self.killCount) + " kills"
		return self.user.username

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
		('SE', 'Search'),
		('GV', 'Get Venue'),
		('FN', 'Find Nearby Venues'),
		('ST', 'Set Trap'),
		('NT', 'No Trap'),
		('HT', 'Hit Trap'),
		('FI', 'Found Item'),
		('UI', 'Used Item'),
		('GC', 'Got Coins'),
		('PC', 'Purchase'),
		('RF', 'Request Friend'),
		('AF', 'Accept Friend'),
		('DF', 'Deny Friend'),
		('SM', 'Send Message'),
		('RM', 'Receive Message'),
		('LI', 'Log In'),
	)
	type = models.CharField(max_length=2, choices=EVENT_CHOICES)
	data1 = models.CharField(max_length=20)
	data2 = models.CharField(max_length=20)
	dateTime = models.DateTimeField(auto_now_add=True)
	user = models.ForeignKey(TrapsUser)

	def __unicode__(self):
		longtype = [i for i in self.EVENT_CHOICES if self.type in i][0][1]		
		return str(self.user) + " "+longtype + " at " + str(self.dateTime) + " " + self.data1 + " " + self.data2

class VenueItem(models.Model):
	venue = models.ForeignKey(Venue)
	item = models.ForeignKey(Item)	
	
	def __unicode__(self):
		return str(self.venue) + " has a " + str(self.item)

class UserItem(models.Model):
	user = models.ForeignKey(TrapsUser)
	item = models.ForeignKey(Item)	
	isHolding = models.BooleanField(default=True)

	def __unicode__(self):
		return str(self.user) + " owns a " + str(self.item)
