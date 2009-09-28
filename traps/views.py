from django.shortcuts import render_to_response
from Traps.traps.models import Venue

# Create your views here.

def DropTrap(request):
	venues = Venue.objects.all()
	sendable_venues = [{'name':v.name, 'phone':v.phone, 'longitude':v.longitude} for v in venues]
	ret = {'venues':sendable_venues}
	print ret
	return render_to_response('nearbyplaces.html', ret)
