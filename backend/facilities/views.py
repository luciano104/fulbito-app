from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone
from datetime import datetime, timedelta

from .models import Facility, Court, BaseSchedule, Reservation, Review, Favorite
from .serializers import (
    FacilitySerializer,
    FacilityListSerializer,
    CourtSerializer,
    BaseScheduleSerializer,
    ReservationSerializer,
    ReviewSerializer,
    FavoriteSerializer,
)
from users.models import User


# ─────────────────────────────────────────────
#  COMPLEJOS
# ─────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_facility(request):
    """El dueño registra su complejo al registrarse."""
    serializer = FacilitySerializer(data=request.data)
    if serializer.is_valid():
        facility = serializer.save(admin=request.user)

        #Cancha por defecto
        court = Court.objects.create(
            facility = facility,
            team_size = 'F5',
            surface=facility.surface_type,
            price=facility.base_price,
            available = True,
        )
        horarios = [
            ('16:00:00', '17:00:00'),
            ('17:00:00', '18:00:00'),
            ('18:00:00', '19:00:00'),
            ('19:00:00', '20:00:00'),
            ('20:00:00', '21:00:00'),
            ('21:00:00', '22:00:00'),
        ]
        for start, end in horarios:
            BaseSchedule.objects.create(
                court=court,
                start_time=start,
                end_time=end,
            )
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([AllowAny])
def list_facilities(request):
    """Lista todos los complejos. El jugador ve esto en su Home."""
    facilities = Facility.objects.all()
    serializer = FacilityListSerializer(facilities, many=True)
    return Response({'facilities': serializer.data}, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_facility_details(request, id):
    """Detalle completo de un complejo con sus canchas y reseñas."""
    try:
        facility = Facility.objects.get(id=id)
    except Facility.DoesNotExist:
        return Response({'message': 'Complejo no encontrado'}, status=status.HTTP_404_NOT_FOUND)

    courts = Court.objects.filter(facility=facility)
    reviews = Review.objects.filter(reservation__schedule__court__facility=facility)

    return Response({
        'facility': FacilitySerializer(facility).data,
        'courts': CourtSerializer(courts, many=True).data,
        'reviews': ReviewSerializer(reviews, many=True).data,
    }, status=status.HTTP_200_OK)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_facility(request, id):
    """El dueño actualiza los datos de su complejo."""
    try:
        facility = Facility.objects.get(id=id)
    except Facility.DoesNotExist:
        return Response({'message': 'Complejo no encontrado'}, status=status.HTTP_404_NOT_FOUND)

    if facility.admin.id != request.user.id:
        return Response({'message': 'No tenés permiso para modificar este complejo'}, status=status.HTTP_403_FORBIDDEN)

    serializer = FacilitySerializer(facility, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_stats(request, facility_id):
    """Estadísticas del día para el panel del dueño."""
    try:
        facility = Facility.objects.get(id=facility_id)
    except Facility.DoesNotExist:
        return Response({'message': 'Complejo no encontrado'}, status=status.HTTP_404_NOT_FOUND)

    if facility.admin.id != request.user.id:
        return Response({'message': 'No tenés permiso'}, status=status.HTTP_403_FORBIDDEN)

    from django.utils import timezone
    fecha_hoy = timezone.localtime().date()
    reservas_hoy = Reservation.objects.filter(
        schedule__court__facility=facility,
        date=fecha_hoy,
        status__in=[Reservation.STATUS_CONFIRMED, Reservation.STATUS_COMPLETED]
    )

    turnos_hoy = reservas_hoy.count()
    ingresos = sum(
        r.schedule.court.price for r in reservas_hoy
    )
    total_slots = BaseSchedule.objects.filter(
        court__facility=facility,
        court__available=True
    ).count()

    ocupacion = round((turnos_hoy / total_slots * 100), 1) if total_slots > 0 else 0.0

    return Response({
        'turnos_hoy': turnos_hoy,
        'ingresos_estimados': float(ingresos),
        'porcentaje_ocupacion': ocupacion,
        'avg_rating': facility.avg_rating,
        'total_reviews': facility.total_reviews,
    }, status=status.HTTP_200_OK)

# ─────────────────────────────────────────────
#  CANCHAS
# ─────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_court(request, facility_id):
    """El dueño agrega una cancha a su complejo."""
    try:
        facility = Facility.objects.get(id=facility_id)
    except Facility.DoesNotExist:
        return Response({'message': 'Complejo no encontrado'}, status=status.HTTP_404_NOT_FOUND)

    if facility.admin.id != request.user.id:
        return Response({'message': 'No tenés permiso'}, status=status.HTTP_403_FORBIDDEN)

    serializer = CourtSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(facility=facility)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def toggle_availability(request, court_id):
    """El dueño pausa/reactiva una cancha por mantenimiento."""
    try:
        court = Court.objects.get(id=court_id)
    except Court.DoesNotExist:
        return Response({'message': 'Cancha no encontrada'}, status=status.HTTP_404_NOT_FOUND)

    if court.facility.admin.id != request.user.id:
        return Response({'message': 'No tenés permiso'}, status=status.HTTP_403_FORBIDDEN)

    court.available = not court.available
    court.save()
    return Response({'available': court.available}, status=status.HTTP_200_OK)

# ─────────────────────────────────────────────
#  HORARIOS
# ─────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_schedule(request, court_id):
    """El dueño define un bloque horario semanal para una cancha."""
    try:
        court = Court.objects.get(id=court_id)
    except Court.DoesNotExist:
        return Response({'message': 'Cancha no encontrada'}, status=status.HTTP_404_NOT_FOUND)

    serializer = BaseScheduleSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(court=court)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_schedules(request, court_id):
    date_str = request.query_params.get('date')
    show_all = request.query_params.get('show_all', 'false').lower() == 'true'

    try:
        court = Court.objects.get(id=court_id)
    except Court.DoesNotExist:
        return Response({'message': 'Cancha no encontrada'}, status=status.HTTP_404_NOT_FOUND)

    schedules = BaseSchedule.objects.filter(court=court).order_by('start_time')

    if date_str:
        fecha = datetime.strptime(date_str, '%Y-%m-%d').date()
        fecha_hoy = timezone.localtime().date()
        hora_ahora = timezone.localtime().time()

        reservados = Reservation.objects.filter(
            schedule__court=court,
            date=fecha,
            status__in=[Reservation.STATUS_PENDING, Reservation.STATUS_CONFIRMED, Reservation.STATUS_COMPLETED]
        ).values_list('schedule_id', flat=True)

        if not show_all and fecha == fecha_hoy:
            limite = (datetime.combine(fecha_hoy, hora_ahora) + timedelta(minutes=15)).time()
            schedules = schedules.filter(start_time__gt=limite)

        data = []
        for schedule in schedules:
            s = BaseScheduleSerializer(schedule).data
            s['occupied'] = schedule.id in reservados
            if fecha == fecha_hoy:
                s['passed'] = schedule.end_time <= hora_ahora
            else:
                s['passed'] = fecha < fecha_hoy
            data.append(s)

        return Response({'schedules': data}, status=status.HTTP_200_OK)

    return Response(
        {'schedules': BaseScheduleSerializer(schedules, many=True).data},
        status=status.HTTP_200_OK
    )
# ─────────────────────────────────────────────
#  RESERVAS
# ─────────────────────────────────────────────

def actualizar_reservas_completadas(reservations_qs):
    """Marca como completed las reservas cuya hora final ya pasó."""
    ahora = timezone.localtime()
    fecha_hoy = ahora.date()
    hora_ahora = ahora.time()

    for reserva in reservations_qs.filter(status=Reservation.STATUS_CONFIRMED):
        fin = reserva.schedule.end_time
        if reserva.date < fecha_hoy or (reserva.date == fecha_hoy and fin <= hora_ahora):
            reserva.status = Reservation.STATUS_COMPLETED
            reserva.save()


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_reservation(request):
    facility_id = request.data.get('facility_id')
    date = request.data.get('date')
    start_time = request.data.get('start_time')

    try:
        facility = Facility.objects.get(id=facility_id)
    except Facility.DoesNotExist:
        return Response({'message': 'Complejo no encontrado'}, status=status.HTTP_404_NOT_FOUND)

    courts = Court.objects.filter(facility=facility, available=True)

    for court in courts:
        try:
            schedule = BaseSchedule.objects.get(court=court, start_time=start_time)
        except BaseSchedule.DoesNotExist:
            continue
        already_reserved = Reservation.objects.filter(
            schedule=schedule,
            date=date,
            status__in=[Reservation.STATUS_PENDING, Reservation.STATUS_CONFIRMED]
        ).exists()

        if not already_reserved:
            reservation = Reservation.objects.create(
                schedule=schedule,
                player=request.user,
                date=date,
                status=Reservation.STATUS_PENDING
            )
            serializer = ReservationSerializer(reservation)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

    return Response(
        {'message': 'No hay canchas disponibles para ese horario'},
        status=status.HTTP_400_BAD_REQUEST
    )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_reservations(request):
    """El jugador ve su historial de reservas."""
    reservations = Reservation.objects.filter(player=request.user).order_by('-date')
    serializer = ReservationSerializer(reservations, many=True)
    actualizar_reservas_completadas(reservations)
    return Response({'reservations': serializer.data}, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def facility_reservations(request, facility_id):
    """El dueño ve las reservas de su complejo."""
    try:
        facility = Facility.objects.get(id=facility_id)
    except Facility.DoesNotExist:
        return Response({'message': 'Complejo no encontrado'}, status=status.HTTP_404_NOT_FOUND)

    if facility.admin.id != request.user.id:
        return Response({'message': 'No tenés permiso'}, status=status.HTTP_403_FORBIDDEN)

    reservations = Reservation.objects.filter(
        schedule__court__facility=facility
    ).order_by('-date')

    actualizar_reservas_completadas(reservations)
    serializer = ReservationSerializer(reservations, many=True)
    return Response({'reservations': serializer.data}, status=status.HTTP_200_OK)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def change_status_reservation(request, reservation_id):
    """El dueño confirma o cancela una reserva."""
    try:
        reservation = Reservation.objects.get(id=reservation_id)
    except Reservation.DoesNotExist:
        return Response({'message': 'Reserva no encontrada'}, status=status.HTTP_404_NOT_FOUND)

    new_status = request.data.get('status')
    valid_status = [Reservation.STATUS_CONFIRMED, Reservation.STATUS_CANCELED]

    if new_status not in valid_status:
        return Response(
            {'message': f'Estado inválido. Opciones: {valid_status}'},
            status=status.HTTP_400_BAD_REQUEST
        )

    reservation.status = new_status
    reservation.save()

    return Response(ReservationSerializer(reservation).data, status=status.HTTP_200_OK)

# ─────────────────────────────────────────────
#  RESEÑAS
# ─────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_review(request):
    """El jugador deja una reseña de una reserva finalizada."""
    serializer = ReviewSerializer(data=request.data)
    if serializer.is_valid():
        review = serializer.save()

        # Recalcular el promedio del complejo
        facility = review.reservation.schedule.court.facility
        reviews = Review.objects.filter(
            reservation__schedule__court__facility=facility
        )
        total = reviews.count()
        avg = sum(r.rating for r in reviews) / total

        facility.avg_rating = round(avg, 1)
        facility.total_reviews = total
        facility.save()

        return Response(serializer.data, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ─────────────────────────────────────────────
#  FAVORITOS
# ─────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_favorite(request, facility_id):
    """Agrega o quita un complejo de favoritos del jugador."""
    try:
        facility = Facility.objects.get(id=facility_id)
    except Facility.DoesNotExist:
        return Response({'message': 'Complejo no encontrado'}, status=status.HTTP_404_NOT_FOUND)

    favorite = Favorite.objects.filter(player=request.user, facility=facility).first()

    if favorite:
        # Ya era favorito → lo quitamos
        favorite.delete()
        return Response({'favorite': False}, status=status.HTTP_200_OK)
    else:
        # No era favorito → lo agregamos
        Favorite.objects.create(player=request.user, facility=facility)
        return Response({'favorite': True}, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_favorites(request):
    """El jugador ve sus complejos favoritos."""
    favorites = Favorite.objects.filter(player=request.user)
    facilities = [f.facility for f in favorites]
    serializer = FacilityListSerializer(facilities, many=True)
    return Response({'favorites': serializer.data}, status=status.HTTP_200_OK)