# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):
    
    def forwards(self, orm):
        
        # Deleting field 'TrapsUser.gender'
        db.delete_column('traps_trapsuser', 'gender')
    
    
    def backwards(self, orm):
        
        # Adding field 'TrapsUser.gender'
        db.add_column('traps_trapsuser', 'gender', self.gf('django.db.models.fields.CharField')(default='M', max_length=1), keep_default=False)
    
    
    models = {
        'auth.group': {
            'Meta': {'object_name': 'Group'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '80'}),
            'permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'blank': 'True'})
        },
        'auth.permission': {
            'Meta': {'unique_together': "(('content_type', 'codename'),)", 'object_name': 'Permission'},
            'codename': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'content_type': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['contenttypes.ContentType']"}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        },
        'auth.user': {
            'Meta': {'object_name': 'User'},
            'date_joined': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75', 'blank': 'True'}),
            'first_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Group']", 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True', 'blank': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False', 'blank': 'True'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False', 'blank': 'True'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'last_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'blank': 'True'}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '30'})
        },
        'contenttypes.contenttype': {
            'Meta': {'unique_together': "(('app_label', 'model'),)", 'object_name': 'ContentType', 'db_table': "'django_content_type'"},
            'app_label': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'model': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        'traps.event': {
            'Meta': {'object_name': 'Event'},
            'data1': ('django.db.models.fields.CharField', [], {'max_length': '20'}),
            'data2': ('django.db.models.fields.CharField', [], {'max_length': '20'}),
            'dateTime': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'type': ('django.db.models.fields.CharField', [], {'max_length': '2'}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['traps.TrapsUser']"})
        },
        'traps.item': {
            'Meta': {'object_name': 'Item'},
            'assetPath': ('django.db.models.fields.FilePathField', [], {'path': "'/Users/roderic/dev/Traps/site_media//images/'", 'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'level': ('django.db.models.fields.IntegerField', [], {'default': '1'}),
            'limit': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'note': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'timeToLive': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'type': ('django.db.models.fields.CharField', [], {'max_length': '2'}),
            'value': ('django.db.models.fields.IntegerField', [], {'default': '1'})
        },
        'traps.message': {
            'Meta': {'object_name': 'Message'},
            'dateTime': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'message': ('django.db.models.fields.CharField', [], {'max_length': '200'}),
            'reciever': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'received_messages'", 'to': "orm['traps.TrapsUser']"}),
            'sender': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'sent_messages'", 'to': "orm['traps.TrapsUser']"})
        },
        'traps.trapsuser': {
            'Meta': {'object_name': 'TrapsUser'},
            'coinCount': ('django.db.models.fields.IntegerField', [], {'default': '10'}),
            'fbid': ('django.db.models.fields.IntegerField', [], {'null': 'True', 'blank': 'True'}),
            'friends': ('django.db.models.fields.related.ManyToManyField', [], {'related_name': "'friends_rel_+'", 'to': "orm['traps.TrapsUser']"}),
            'hitPoints': ('django.db.models.fields.IntegerField', [], {'default': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'iphoneDeviceToken': ('django.db.models.fields.CharField', [], {'max_length': '64', 'null': 'True', 'blank': 'True'}),
            'killCount': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'lastUpdated': ('django.db.models.fields.DateTimeField', [], {'auto_now': 'True', 'auto_now_add': 'True', 'blank': 'True'}),
            'level': ('django.db.models.fields.IntegerField', [], {'default': '1'}),
            'photo': ('django.db.models.fields.FilePathField', [], {'max_length': '100', 'path': "'images/avatars'", 'null': 'True', 'blank': 'True'}),
            'trapsSetCount': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'tutorial': ('django.db.models.fields.IntegerField', [], {'default': '1'}),
            'twitterid': ('django.db.models.fields.CharField', [], {'max_length': '15', 'null': 'True', 'blank': 'True'}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['auth.User']", 'unique': 'True'})
        },
        'traps.useritem': {
            'Meta': {'object_name': 'UserItem'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'isHolding': ('django.db.models.fields.BooleanField', [], {'default': 'True', 'blank': 'True'}),
            'item': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['traps.Item']"}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['traps.TrapsUser']"})
        },
        'traps.venue': {
            'Meta': {'object_name': 'Venue'},
            'checkinCount': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'city': ('django.db.models.fields.CharField', [], {'max_length': '30'}),
            'coinValue': ('django.db.models.fields.IntegerField', [], {'default': '3'}),
            'foursquareid': ('django.db.models.fields.IntegerField', [], {}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'item': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['traps.Item']", 'null': 'True', 'blank': 'True'}),
            'lastUpdated': ('django.db.models.fields.DateTimeField', [], {'auto_now': 'True', 'auto_now_add': 'True', 'blank': 'True'}),
            'latitude': ('django.db.models.fields.FloatField', [], {}),
            'longitude': ('django.db.models.fields.FloatField', [], {}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'phone': ('django.db.models.fields.CharField', [], {'max_length': '11'}),
            'state': ('django.db.models.fields.CharField', [], {'max_length': '30'}),
            'streetName': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'zip': ('django.db.models.fields.CharField', [], {'max_length': '10'})
        },
        'traps.venueitem': {
            'Meta': {'object_name': 'VenueItem'},
            'dateTimePlaced': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'dateTimeUsed': ('django.db.models.fields.DateTimeField', [], {'null': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'item': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['traps.Item']"}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['traps.TrapsUser']", 'null': 'True', 'blank': 'True'}),
            'venue': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['traps.Venue']"})
        }
    }
    
    complete_apps = ['traps']
