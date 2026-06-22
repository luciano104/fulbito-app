from django.db import models

class User(models.Model):
	PLAYER_ROLE = 'player'
	OWNER_ROLE = 'owner'

	ROLE_CHOICES = [
		(PLAYER_ROLE, 'Player'),
		(OWNER_ROLE, 'Facility Owner')
	]
	id = models.AutoField(primary_key = True)
	name = models.CharField(max_length = 100)
	lastname = models.CharField(max_length = 100)
	email = models.EmailField(unique = True)
	image=models.CharField(
		max_length = 255,
		null = True,
		blank = True
	)
	password = models.CharField(max_length=255)
	phone = models.CharField(max_length=20, null=True, blank=True)
	notification_token = models.CharField(
		max_length = 255,
		null = True,
		blank = True
	)
	created_at = models.DateTimeField(auto_now_add = True)
	updated_at = models.DateTimeField(auto_now = True)
	
	## para establecer relaciones entre tablas ##
	role = models.CharField(
		max_length=100,
		choices=ROLE_CHOICES,
		default=PLAYER_ROLE
	)

	class Meta:
		db_table ='users'
	
	def __str__(self):
		return f'{self.name} {self.lastname} ({self.role})'