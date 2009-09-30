from django.conf.urls.defaults import *
import os

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # (r'^Traps/', include('Traps.foo.urls')),
    (r'^startup/', 'django.views.generic.simple.direct_to_template', {'template':'nearbyplaces.html'}),
    (r'^FindNearby/', 'Traps.traps.views.FindNearby'),
    (r'^GetVenue/(?P<vid>\d+)', 'Traps.traps.views.GetVenue'),
    (r'^SearchVenue/(?P<vid>\d+)/(?P<uid>\d+)', 'Traps.traps.views.SearchVenue'),
	(r'^site_media/(?P<path>.*)$', 'django.views.static.serve', {'document_root': os.getcwd()+'/site_media'}),

    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
     (r'^admin/', include(admin.site.urls)),
)
