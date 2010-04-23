from django.conf.urls.defaults import *
import os

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

#TODO there has to be a better way to do this...
PRODUCTION_SERVERS = ['web111.webfaction.com']
if os.environ.get('HOSTNAME', '') in PRODUCTION_SERVERS:
	#doc_root = '/home/rodericj/webapps/django/Traps/site_media'
	doc_root = '/home/rodericj/webapps/traps_media/site_media/'
else: 
	#http://192.168.1.110:8000/site_media/bananapeel.png
	doc_root = os.getcwd()+'/site_media/'

urlpatterns = patterns('',
    # Example:
    (r'^startup/', 'django.views.generic.simple.direct_to_template', {'template':'nearbyplaces.html'}),
    (r'^testViews/', 'django.views.generic.simple.direct_to_template', {'template':'testviews.html'}),
    (r'^history/', 'django.views.generic.simple.direct_to_template', {'template':'history.html'}),
    (r'^profile/', 'django.views.generic.simple.direct_to_template', {'template':'profile.html'}),
    (r'^dropHistory/', 'django.views.generic.simple.direct_to_template', {'template':'dropHistory.html'}),
    (r'^loggedOut/', 'django.views.generic.simple.direct_to_template', {'template':'loggedout.html'}),
    (r'^iphone_login/', 'Traps.traps.views.iphone_login'),
    (r'^Login/', 'Traps.traps.views.Login'),
    (r'^app_logout/', 'Traps.traps.views.app_logout'),
    (r'^set_trap/', 'Traps.traps.views.set_trap'),
    (r'^set_device_token/', 'Traps.traps.views.set_device_token'),
    (r'^get_user_feed/', 'Traps.traps.views.get_user_feed'),
    (r'^GetUserHistory/', 'Traps.traps.views.GetUserHistory'),
	(r'^get_friends/', 'Traps.traps.views.get_friends'),
    (r'^GetUserDropHistory/', 'Traps.traps.views.GetUserDropHistory'),
    (r'^GetVenue/(?P<vid>\d+)/', 'Traps.traps.views.GetVenue'),
    (r'^GetUserProfile/(?P<uid>\d*)/?', 'Traps.traps.views.GetUserProfile'),
    (r'^get_my_user_profile/', 'Traps.traps.views.get_my_user_profile'),
    (r'^search_venue/', 'Traps.traps.views.search_venue'),
    (r'^search_venue/(?P<vid>\d+)/', 'Traps.traps.views.search_venue'),
    (r'^ShowAllTrapsSet/', 'Traps.traps.views.ShowAllTrapsSet'),
    (r'^site_media/(?P<path>.*)$', 'django.views.static.serve', {'document_root': doc_root}),
	
	#(r'^qr/(?P<code>\d*)$', 'Traps.traps.views.qr_code'),
	(r'^$', 'Traps.traps.views.home_page'),
	(r'^venue/(?P<eid>\w*)$', 'Traps.traps.views.venue'),


    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
     (r'^admin/', include(admin.site.urls)),
	     
)
