from django.urls import path
from . import views
 
urlpatterns = [
    # Autenticación (no requieren token)
    path('register/', views.register),
    path('login/', views.login),
 
    # Perfil de usuario (requieren token JWT)
    path('user/<int:id>/', views.get_user),
    path('user/<int:id>/update/', views.update_user),
]
 