# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):
    
    def forwards(self, orm):
        
        # Adding model 'Item'
        db.create_table('traps_item', (
            ('assetPath', self.gf('django.db.models.fields.FilePathField')(path='/Users/roderic/dev/Traps/site_media//images/', max_length=100)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=50)),
            ('level', self.gf('django.db.models.fields.IntegerField')(default=1)),
            ('value', self.gf('django.db.models.fields.IntegerField')(default=1)),
            ('note', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('timeToLive', self.gf('django.db.models.fields.IntegerField')(default=0)),
            ('limit', self.gf('django.db.models.fields.IntegerField')(default=0)),
            ('type', self.gf('django.db.models.fields.CharField')(max_length=2)),
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
        ))
        db.send_create_signal('traps', ['Item'])

        # Adding model 'Venue'
        db.create_table('traps_venue', (
            ('city', self.gf('django.db.models.fields.CharField')(max_length=30)),
            ('lastUpdated', self.gf('django.db.models.fields.DateTimeField')(auto_now=True, auto_now_add=True, blank=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=50)),
            ('zip', self.gf('django.db.models.fields.CharField')(max_length=10)),
            ('longitude', self.gf('django.db.models.fields.FloatField')()),
            ('phone', self.gf('django.db.models.fields.CharField')(max_length=11)),
            ('state', self.gf('django.db.models.fields.CharField')(max_length=30)),
            ('foursquareid', self.gf('django.db.models.fields.IntegerField')()),
            ('checkinCount', self.gf('django.db.models.fields.IntegerField')(default=0)),
            ('latitude', self.gf('django.db.models.fields.FloatField')()),
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('streetName', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('coinValue', self.gf('django.db.models.fields.IntegerField')(default=3)),
        ))
        db.send_create_signal('traps', ['Venue'])

        # Adding M2M table for field item on 'Venue'
        db.create_table('traps_venue_item', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('venue', models.ForeignKey(orm['traps.venue'], null=False)),
            ('item', models.ForeignKey(orm['traps.item'], null=False))
        ))
        db.create_unique('traps_venue_item', ['venue_id', 'item_id'])

        # Adding model 'TrapsUser'
        db.create_table('traps_trapsuser', (
            ('level', self.gf('django.db.models.fields.IntegerField')(default=1)),
            ('iphoneDeviceToken', self.gf('django.db.models.fields.CharField')(max_length=64, null=True, blank=True)),
            ('twitterid', self.gf('django.db.models.fields.CharField')(max_length=15, null=True, blank=True)),
            ('trapsSetCount', self.gf('django.db.models.fields.IntegerField')(default=0)),
            ('photo', self.gf('django.db.models.fields.FilePathField')(max_length=100, path='images/avatars', null=True, blank=True)),
            ('fbid', self.gf('django.db.models.fields.IntegerField')(null=True, blank=True)),
            ('coinCount', self.gf('django.db.models.fields.IntegerField')(default=10)),
            ('lastUpdated', self.gf('django.db.models.fields.DateTimeField')(auto_now=True, auto_now_add=True, blank=True)),
            ('user', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['auth.User'], unique=True)),
            ('gender', self.gf('django.db.models.fields.CharField')(max_length=1)),
            ('hitPoints', self.gf('django.db.models.fields.IntegerField')(default=100)),
            ('killCount', self.gf('django.db.models.fields.IntegerField')(default=0)),
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('tutorial', self.gf('django.db.models.fields.IntegerField')(default=1)),
        ))
        db.send_create_signal('traps', ['TrapsUser'])

        # Adding M2M table for field friends on 'TrapsUser'
        db.create_table('traps_trapsuser_friends', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('from_trapsuser', models.ForeignKey(orm['traps.trapsuser'], null=False)),
            ('to_trapsuser', models.ForeignKey(orm['traps.trapsuser'], null=False))
        ))
        db.create_unique('traps_trapsuser_friends', ['from_trapsuser_id', 'to_trapsuser_id'])

        # Adding model 'Message'
        db.create_table('traps_message', (
            ('message', self.gf('django.db.models.fields.CharField')(max_length=200)),
            ('reciever', self.gf('django.db.models.fields.related.ForeignKey')(related_name='received_messages', to=orm['traps.TrapsUser'])),
            ('dateTime', self.gf('django.db.models.fields.DateTimeField')(auto_now_add=True, blank=True)),
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('sender', self.gf('django.db.models.fields.related.ForeignKey')(related_name='sent_messages', to=orm['traps.TrapsUser'])),
        ))
        db.send_create_signal('traps', ['Message'])

        # Adding model 'Event'
        db.create_table('traps_event', (
            ('type', self.gf('django.db.models.fields.CharField')(max_length=2)),
            ('dateTime', self.gf('django.db.models.fields.DateTimeField')(auto_now_add=True, blank=True)),
            ('user', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['traps.TrapsUser'])),
            ('data1', self.gf('django.db.models.fields.CharField')(max_length=20)),
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('data2', self.gf('django.db.models.fields.CharField')(max_length=20)),
        ))
        db.send_create_signal('traps', ['Event'])

        # Adding model 'VenueItem'
        db.create_table('traps_venueitem', (
            ('venue', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['traps.Venue'])),
            ('item', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['traps.Item'])),
            ('user', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['traps.TrapsUser'], null=True, blank=True)),
            ('dateTimePlaced', self.gf('django.db.models.fields.DateTimeField')(auto_now_add=True, blank=True)),
            ('dateTimeUsed', self.gf('django.db.models.fields.DateTimeField')(null=True)),
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
        ))
        db.send_create_signal('traps', ['VenueItem'])

        # Adding model 'UserItem'
        db.create_table('traps_useritem', (
            ('isHolding', self.gf('django.db.models.fields.BooleanField')(default=True, blank=True)),
            ('item', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['traps.Item'])),
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('user', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['traps.TrapsUser'])),
        ))
        db.send_create_signal('traps', ['UserItem'])
    
    
    def backwards(self, orm):
        
        # Deleting model 'Item'
        db.delete_table('traps_item')

        # Deleting model 'Venue'
        db.delete_table('traps_venue')

        # Removing M2M table for field item on 'Venue'
        db.delete_table('traps_venue_item')

        # Deleting model 'TrapsUser'
        db.delete_table('traps_trapsuser')

        # Removing M2M table for field friends on 'TrapsUser'
        db.delete_table('traps_trapsuser_friends')

        # Deleting model 'Message'
        db.delete_table('traps_message')

        # Deleting model 'Event'
        db.delete_table('traps_event')

        # Deleting model 'VenueItem'
        db.delete_table('traps_venueitem')

        # Deleting model 'UserItem'
        db.delete_table('traps_useritem')
    
    
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
            'gender': ('django.db.models.fields.CharField', [], {'max_length': '1'}),
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
