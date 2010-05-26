import os

PRODUCTION_SERVERS = ['web111.webfaction.com']

if os.environ.get('HOSTNAME', '') in PRODUCTION_SERVERS:
	PRODUCTION = True

	MEDIA_DIRECTORY = '/trap_media'
	MEDIA_ROOT = '/home/rodericj/webapps'+MEDIA_DIRECTORY
	MEDIA_URL = 'http://thetrapgame.com/site_media'

	ADMIN_MEDIA_PREFIX = 'http://thetrapgame.com/media/admin/'

	TEMPLATE_DIRS = (
    	# Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    	# Always use forward slashes, even on Windows.
    	# Don't forget to use absolute paths, not relative paths.
		'/home/rodericj/webapps/django/Traps/templates/'
	)

else:
	PRODUCTION = False

	MEDIA_DIRECTORY = '/site_media'
	MEDIA_ROOT = os.getcwd()+MEDIA_DIRECTORY
	MEDIA_URL = '/site_media/'

	ADMIN_MEDIA_PREFIX = '/media/'

	TEMPLATE_DIRS = (
		os.getcwd()+'/templates/',
	)


yelp_api_key = 'Ad6eKfALxhzXVw_WqsWo7A'

startVenueWithCoins = 3
startVenueWithChanceOfDrop = .1 
startUserWithCoins = 10
numStarterItems = 3

golden_egg_iid=3
banana_iid=1
tutorial1 = "Hey and welcome to The Trap Game. The purpose is to find things laying around your city. Start out by clicking the big 'Search Places' Button."
tutorial2 = "Looks like you found the nearby venues. Lets tap one of them and find some cool stuff. Don't forget that you can drop traps."
tutorial3 = "Great news. You found an old banana peel that you can use as a trap.  Would you like to set a trap here for the next person who tries to search here?  (you should, just to keep it interesting)"
tutorial4 = "Hey looks like you found a cool item there. I wonder what other things we can find. Let's search another place."
