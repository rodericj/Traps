from django.conf.urls.defaults import *
import os

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # (r'^Traps/', include('Traps.foo.urls')),
    (r'^startup/', 'django.views.generic.simple.direct_to_template', {'template':'nearbyplaces.html'}),
    (r'^history/', 'django.views.generic.simple.direct_to_template', {'template':'history.html'}),
    (r'^profile/', 'django.views.generic.simple.direct_to_template', {'template':'profile.html'}),
    (r'^dropHistory/', 'django.views.generic.simple.direct_to_template', {'template':'dropHistory.html'}),
    (r'^loggedOut/', 'django.views.generic.simple.direct_to_template', {'template':'loggedout.html'}),
    (r'^IPhoneLogin/', 'Traps.traps.views.IPhoneLogin'),
    (r'^Login/', 'Traps.traps.views.Login'),
    (r'^Logout/', 'Traps.traps.views.Logout'),
    #(r'^FindNearby/', 'Traps.traps.views.FindNearby'),
    #(r'^SetTrap/(?P<vid>\d+)/(?P<iid>\d+)/(?P<uid>\d+)/', 'Traps.traps.views.SetTrap'),
    (r'^SetTrap/', 'Traps.traps.views.SetTrap'),
    (r'^SetDeviceToken/', 'Traps.traps.views.SetDeviceToken'),
    (r'^GetUserHistory/', 'Traps.traps.views.GetUserHistory'),
	(r'^GetFriends/', 'Traps.traps.views.GetFriends'),
    (r'^GetUserDropHistory/', 'Traps.traps.views.GetUserDropHistory'),
    (r'^GetVenue/(?P<vid>\d+)/', 'Traps.traps.views.GetVenue'),
    (r'^GetUserProfile/(?P<uid>\d*)/?', 'Traps.traps.views.GetUserProfile'),
    (r'^SearchVenue/', 'Traps.traps.views.SearchVenue'),
    (r'^SearchVenue/(?P<vid>\d+)/', 'Traps.traps.views.SearchVenue'),
    (r'^ShowAllTrapsSet/', 'Traps.traps.views.ShowAllTrapsSet'),
	(r'^site_media/(?P<path>.*)$', 'django.views.static.serve', {'document_root': os.getcwd()+'/site_media'}),
	(r'^$', 'Traps.traps.views.holding'),


    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
     (r'^admin/', include(admin.site.urls)),
	     
)
