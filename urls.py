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
    (r'^Login/', 'Traps.traps.views.Login'),
    (r'^Logout/', 'Traps.traps.views.Logout'),
    (r'^ProfileRefresh/', 'Traps.traps.views.ProfileRefresh'),
    (r'^FindNearby/', 'Traps.traps.views.FindNearby'),
    (r'^SetTrap/(?P<vid>\d+)/(?P<iid>\d+)/(?P<uid>\d+)/', 'Traps.traps.views.SetTrap'),
    (r'^GetUserHistory/', 'Traps.traps.views.GetUserHistory'),
    (r'^GetUserDropHistory/', 'Traps.traps.views.GetUserDropHistory'),
    (r'^GetVenue/(?P<vid>\d+)/', 'Traps.traps.views.GetVenue'),
    (r'^GetUserProfile/(?P<uid>\d*)/?', 'Traps.traps.views.GetUserProfile'),
    (r'^SearchVenue/(?P<vid>\d+)/', 'Traps.traps.views.SearchVenue'),
	(r'^site_media/(?P<path>.*)$', 'django.views.static.serve', {'document_root': os.getcwd()+'/site_media'}),

    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
     (r'^admin/', include(admin.site.urls)),
)
