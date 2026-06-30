from django.urls import path
from . import views

urlpatterns = [

    # Complejos
    path('facilities/', views.list_facilities),
    path('facilities/create/', views.create_facility),
    path('facilities/<int:id>/', views.get_facility_details),
    path('facilities/<int:id>/update/', views.update_facility),
    path('facilities/<int:facility_id>/dashboard/', views.dashboard_stats),

    # Canchas
    path('facilities/<int:facility_id>/courts/create/', views.create_court),
    path('courts/<int:court_id>/availability/', views.toggle_availability),
    path('courts/<int:court_id>/update/', views.update_court),
    path('courts/<int:court_id>/delete/', views.delete_court),

    # Horarios
    path('courts/<int:court_id>/schedules/', views.list_schedules),
    path('courts/<int:court_id>/schedules/create/', views.create_schedule),
    path('facilities/<int:facility_id>/schedules/add/', views.create_schedule_all_courts),
    path('schedules/<int:schedule_id>/delete/', views.delete_schedule),

    # Reservas
    path('reservations/create/', views.create_reservation),
    path('reservations/my_reservations/', views.my_reservations),
    path('reservations/<int:reservation_id>/status/', views.change_status_reservation),
    path('facilities/<int:facility_id>/reservations/', views.facility_reservations),

    # Reseñas
    path('reviews/create/', views.create_review),

    # Favoritos
    path('facilities/<int:facility_id>/favorite/', views.toggle_favorite),
    path('favorites/', views.my_favorites),

    #Mercado Pago
    path('payments/create-preference/', views.create_mp_preference),
    path('payments/webhook/', views.payment_webhook),
]