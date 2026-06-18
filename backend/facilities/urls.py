from django.urls import path
from . import views

urlpatterns = [

    # Complejos
    path('facilities/', views.list_facilities),
    path('facilities/create/', views.create_facility),
    path('facilities/<int:id>/', views.get_facility_details),
    path('facilities/<int:id>/update/', views.update_facility),

    # Canchas
    path('facilities/<int:facility_id>/courts/create/', views.create_court),
    path('courts/<int:court_id>/availability/', views.toggle_availability),

    # Horarios
    path('courts/<int:court_id>/schedules/', views.list_schedules),
    path('courts/<int:court_id>/schedules/create/', views.create_schedule),

    # Reservas
    path('reservations/create/', views.create_reservation),
    path('reservations/my-reservations/', views.my_reservations),
    path('reservations/<int:reservation_id>/status/', views.change_status_reservation),
    path('facilities/<int:facility_id>/reservations/', views.facility_reservations),

    # Reseñas
    path('reviews/create/', views.create_review),

    # Favoritos
    path('facilities/<int:facility_id>/favorite/', views.toggle_favorite),
    path('favorites/', views.my_favorites),
]