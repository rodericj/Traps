# Django settings for Traps project.
import os
import config

PRODUCTION = config.PRODUCTION

#DEBUG = True
DEBUG = False
TEMPLATE_DEBUG = DEBUG
TEMPLATE_DIRS = config.TEMPLATE_DIRS

ADMINS = (
    # ('Your Name', 'your_email@domain.com'),
     ('roderic', 'roderic@gmail.com'),
)

MANAGERS = ADMINS

if PRODUCTION:
	DATABASE_ENGINE = 'mysql'           # 'postgresql_psycopg2', 'postgresql', 'mysql', 'sqlite3' or 'oracle'.
	DATABASE_NAME = 'rodericj_traps'             # Not used with sqlite3.
	DATABASE_USER = 'rodericj_traps'             # Not used with sqlite3.
	#DATABASE_PASSWORD = 'bananarama'         # Not used with sqlite3.
	DATABASE_PASSWORD = 'ac07551e'         # Not used with sqlite3.
	DATABASE_HOST = 'web111.webfaction.com'             # Set to empty string for localhost. Not used with sqlite3.
	DATABASE_PORT = ''             # Set to empty string for default. Not used with sqlite3.

else:
	DATABASE_ENGINE = 'sqlite3'           # 'postgresql_psycopg2', 'postgresql', 'mysql', 'sqlite3' or 'oracle'.
	DATABASE_NAME = '/tmp/traps.db'             # Or path to database file if using sqlite3.
	DATABASE_USER = ''             # Not used with sqlite3.
	DATABASE_PASSWORD = ''         # Not used with sqlite3.
	DATABASE_HOST = ''             # Set to empty string for localhost. Not used with sqlite3.
	DATABASE_PORT = ''             # Set to empty string for default. Not used with sqlite3.

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'America/Chicago'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# Absolute path to the directory that holds media.
# Example: "/home/media/media.lawrence.com/"

MEDIA_ROOT = config.MEDIA_ROOT

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash if there is a path component (optional in other cases).
# Examples: "http://media.lawrence.com", "http://example.com/media/"
MEDIA_URL = config.MEDIA_URL

# URL prefix for admin media -- CSS, JavaScript and images. Make sure to use a
# trailing slash.
# Examples: "http://foo.com/media/", "/media/".
ADMIN_MEDIA_PREFIX = config.ADMIN_MEDIA_PREFIX

LOGIN_URL = '/admin'

# Make this unique, and don't share it with anybody.
SECRET_KEY = 'yd_9ogfx_!&0$qk^l(_3gcemx8r81d))4tab1xs98d_dhkf0z#'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.load_template_source',
    'django.template.loaders.app_directories.load_template_source',
#     'django.template.loaders.eggs.load_template_source',
)

AUTH_PROFILE_MODULE = 'traps.TrapsUser'

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
)

ROOT_URLCONF = 'Traps.urls'

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
	'django.contrib.admin',
	'south',
	'Traps.traps',
)

EMAIL_HOST = 'smtp.webfaction.com'
EMAIL_HOST_USER = 'rodericj'
EMAIL_HOST_PASSWORD = 'emailpass'
DEFAULT_FROM_EMAIL = 'roderic@gmail.com'
SERVER_EMAIL = 'roderic@gmail.com'

if PRODUCTION:
	IPHONE_APN_PUSH_CERT = '/Users/roderic/dev/Traps/iPhoneSDKCertificates/push_certs/apns-dev.pem'
else:
	IPHONE_APN_PUSH_CERT = '/Users/roderic/dev/Traps/iPhoneSDKCertificates/push_certs/apns-dev.pem'
