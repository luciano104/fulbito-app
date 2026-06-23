from rest_framework import serializers
from .models import Facility, Court, BaseSchedule, Reservation, Review, Favorite

# ─────────────────────────────────────────────
#  COMPLEJO
# ─────────────────────────────────────────────

class FacilitySerializer(serializers.ModelSerializer):

    class Meta:
        model = Facility
        fields = [
            'id',
            'admin',
            'name',
            'address',
            'latitude',
            'longitude',
            'base_price',
            'surface_type',
            'avg_rating',
            'total_reviews',
            'image',
        ]
        extra_kwargs = {
            # El admin se asigna automáticamente desde la view, no lo manda Flutter
            'admin': {'read_only': True},
            # Estos campos los calcula Django, Flutter no los manda
            'avg_rating': {'read_only': True},
            'total_reviews': {'read_only': True},
        }


class FacilityListSerializer(serializers.ModelSerializer):
    """
    Versión resumida para mostrar en el listado del Home del jugador.
    No incluye todos los campos para que la respuesta sea más liviana.
    """
    class Meta:
        model = Facility
        fields = [
            'id',
            'name',
            'address',
            'latitude',
            'longitude',
            'base_price',
            'surface_type',
            'avg_rating',
            'total_reviews',
            'image',
        ]

# ─────────────────────────────────────────────
#  CANCHA
# ─────────────────────────────────────────────

class CourtSerializer(serializers.ModelSerializer):

    class Meta:
        model = Court
        fields = [
            'id',
            'facility',
            'team_size',
            'surface',
            'price',
            'available',
        ]
        extra_kwargs = {
            'facility': {'read_only': True},
        }

# ─────────────────────────────────────────────
#  HORARIO BASE
# ─────────────────────────────────────────────

class BaseScheduleSerializer(serializers.ModelSerializer):

    class Meta:
        model = BaseSchedule
        fields = [
            'id',
            'court',
            'weekday',
            'start_time',
            'end_time',
        ]

# ─────────────────────────────────────────────
#  RESERVA
# ─────────────────────────────────────────────

class ReservationSerializer(serializers.ModelSerializer):

    # Campos de solo lectura que se agregan para que Flutter
    # tenga contexto sin hacer consultas extra
    facility_name = serializers.CharField(
        source='schedule.court.facility.name',
        read_only=True
    )
    court_type = serializers.CharField(
        source='schedule.court.team_size',
        read_only=True
    )
    start_time = serializers.TimeField(
        source='schedule.start_time',
        read_only=True
    )
    end_time = serializers.TimeField(
        source='schedule.end_time',
        read_only=True
    )
    has_review = serializers.SerializerMethodField()

    class Meta:
        model = Reservation
        fields = [
            'id',
            'schedule',
            'player',
            'date',
            'status',
            'facility_name',
            'court_type',
            'start_time',
            'end_time',
            'has_review',
            'created_at',
        ]
        extra_kwargs = {
            'player': {'read_only': True},
        }

    def get_has_review(self, obj):
        """Indica si la reserva ya tiene una reseña, para deshabilitar el formulario en Flutter."""
        return hasattr(obj, 'review')


# ─────────────────────────────────────────────
#  RESEÑA
# ─────────────────────────────────────────────

class ReviewSerializer(serializers.ModelSerializer):

    player_name = serializers.CharField(
        source='reservation.player.name',
        read_only=True
    )

    class Meta:
        model = Review
        fields = [
            'id',
            'reservation',
            'rating',
            'comment',
            'published_at',
            'player_name',
        ]
        extra_kwargs = {
            'published_at': {'read_only': True},
        }

    def validate_puntuacion(self, value):
        """Valida que la puntuación esté entre 1 y 5."""
        if value < 1 or value > 5:
            raise serializers.ValidationError('La puntuación debe estar entre 1 y 5.')
        return value

    def validate_reserva(self, value):
        """Valida que la reserva esté finalizada antes de permitir la reseña."""
        if value.estado != Reservation.ESTADO_FINALIZADA:
            raise serializers.ValidationError(
                'Solo podés dejar una reseña cuando la reserva está finalizada.'
            )
        return value


# ─────────────────────────────────────────────
#  FAVORITO
# ─────────────────────────────────────────────

class FavoriteSerializer(serializers.ModelSerializer):

    class Meta:
        model = Favorite
        fields = [
            'id',
            'player',
            'facility',
            'created_at',
        ]
        extra_kwargs = {
            'player': {'read_only': True},
            'created_at': {'read_only': True},
        }