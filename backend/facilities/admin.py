from django.contrib import admin
from .models import Facility, Court, BaseSchedule, Reservation, Review, Favorite

admin.site.register(Facility)
admin.site.register(Court)
admin.site.register(BaseSchedule)
admin.site.register(Reservation)
admin.site.register(Review)
admin.site.register(Favorite)