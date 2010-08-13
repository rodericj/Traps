class IsLoggedInDecorator:
     
	f = None
	def __init__(self, f):
		print "  inside decorator init"
		self.f = f
	def __call__(self, f, *args):
		print "    inside __call"
		def wrapped_f(*args):
			print "      IsLoggedInDecorator executed"
			self.f(*args)
		return	wrapped_f
