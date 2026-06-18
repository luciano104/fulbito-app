from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status

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
        serializer.save(admin=request.user)
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
    """Lista los horarios disponibles de una cancha para una fecha dada."""
    date = request.query_params.get('date')

    try:
        court = Court.objects.get(id=court_id)
    except Court.DoesNotExist:
        return Response({'message': 'Cancha no encontrada'}, status=status.HTTP_404_NOT_FOUND)

    schedules = BaseSchedule.objects.filter(court=court)

    # Si se pasa una fecha, marcamos cuáles ya están reservados
    if date:
        reserved = Reservation.objects.filter(
            court__schedule=court,
            date=date,
            status__in=[Reservation.STATUS_PENDING, Reservation.STATUS_CONFIRMED]
        ).values_list('schedule_id', flat=True)

        data = []
        for schedule in schedules:
            s = BaseScheduleSerializer(schedule).data
            s['occupied'] = schedule.id in reserved
            data.append(s)

        return Response({'schedules': data}, status=status.HTTP_200_OK)

    return Response(
        {'schedules': BaseScheduleSerializer(schedules, many=True).data},
        status=status.HTTP_200_OK
    )

# ─────────────────────────────────────────────
#  RESERVAS
# ─────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_reservation(request):
    """El jugador solicita una reserva."""
    serializer = ReservationSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(player=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_reservations(request):
    """El jugador ve su historial de reservas."""
    reservations = Reservation.objects.filter(player=request.user).order_by('-date')
    serializer = ReservationSerializer(reservations, many=True)
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

    reservation.estado = new_status
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
        facility = review.reserva.horario.cancha.complejo
        reviews = review.objects.filter(
            review__schedule__court__facility=facility
        )
        total = review.count()
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
    facilities = [f.facilities for f in favorites]
    serializer = FacilityListSerializer(facilities, many=True)
    return Response({'favorites': serializer.data}, status=status.HTTP_200_OK)