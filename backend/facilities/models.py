from django.db import models

# ─────────────────────────────────────────────
#  COMPLEJO
#  Un dueño (Usuario con rol='dueno') puede tener un complejo.
#  Relación OneToOne: un dueño = un complejo.
# ─────────────────────────────────────────────

class Facility(models.Model):
    GRASS_SURFACE = 'grass'
    TURF_SURFACE = 'turf'
    CONCRETE_SURFACE = 'concrete'
    DIRT_SURFACE = 'dirt'

    SURFACE_CHOICES = [
        (GRASS_SURFACE, 'Natural Grass'),
        (TURF_SURFACE, 'Artificial turf'),
        (CONCRETE_SURFACE, 'Concrete'),
        (DIRT_SURFACE, 'Dirt'),
    ]
    # OneToOneField = un dueño tiene exactamente un complejo
    # Si se borra el usuario dueño, se borra el complejo también (CASCADE)
    admin = models.OneToOneField(
        'users.User',
        on_delete=models.CASCADE,
        related_name='facility'
    )

    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    latitude = models.FloatField()
    longitude = models.FloatField()
    base_price = models.DecimalField(max_digits=8, decimal_places=2)
    surface_type = models.CharField(
        max_length=20,
        choices=SURFACE_CHOICES,
        default=TURF_SURFACE
    )

    # Promedio de estrellas — se recalcula cada vez que llega una reseña nueva
    avg_rating = models.FloatField(default=0.0)
    total_reviews = models.IntegerField(default=0)

    image = models.CharField(max_length=255, null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'facilities'

    def __str__(self):
        return self.name


# ─────────────────────────────────────────────
#  CANCHA
#  Un complejo puede tener varias canchas.
#  Relación ForeignKey: muchas canchas → un complejo.
# ─────────────────────────────────────────────

class Court(models.Model):

    TYPE_CHOICES = [
        ('F5', 'Fútbol 5'),
        ('F7', 'Fútbol 7'),
        ('F11', 'Fútbol 11'),
    ]

    facility = models.ForeignKey(
        Facility,
        on_delete=models.CASCADE,
        related_name='courts'
    )

    team_size = models.CharField(
        max_length=3,
        choices=TYPE_CHOICES,
        default='F5'
    )
    surface = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=8, decimal_places=2)

    # Permite pausar la cancha por mantenimiento desde el panel del dueño
    available = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'courts'

    def __str__(self):
        return f'{self.facility.name} - {self.team_size}'


# ─────────────────────────────────────────────
#  HORARIO BASE
#  Define la plantilla semanal de disponibilidad de una cancha.
#  Ej: "Cancha 1 disponible los Lunes de 10:00 a 11:00"
# ─────────────────────────────────────────────

class BaseSchedule(models.Model):

    DAY_CHOICES = [
        ('monday', 'Lunes'),
        ('tuesday', 'Martes'),
        ('wednesday', 'Miércoles'),
        ('thursday', 'Jueves'),
        ('friday', 'Viernes'),
        ('saturday', 'Sábado'),
        ('sunday', 'Domingo'),
    ]

    court = models.ForeignKey(
        Court,
        on_delete=models.CASCADE,
        related_name='schedules'
    )

    weekday = models.CharField(max_length=10, choices=DAY_CHOICES)
    start_time = models.TimeField()
    end_time = models.TimeField()

    class Meta:
        db_table = 'base_schedules'
        # Un mismo horario no puede estar duplicado para la misma cancha
        unique_together = ('court', 'weekday', 'start_time')

    def __str__(self):
        return f'{self.court} - {self.weekday} {self.start_time}'


# ─────────────────────────────────────────────
#  RESERVA
#  Una transacción concreta: jugador reserva un horario en una fecha.
# ─────────────────────────────────────────────

class Reservation(models.Model):

    STATUS_PENDING = 'pending'
    STATUS_CONFIRMED = 'confirmed'
    STATUS_CANCELED = 'canceled'
    STATUS_COMPLETED = 'completed'

    STATUS_CHOICES = [
        (STATUS_PENDING, 'Pending'),
        (STATUS_CONFIRMED, 'Confirmed'),
        (STATUS_CANCELED, 'Canceled'),
        (STATUS_COMPLETED, 'Completed'),
    ]

    schedule = models.ForeignKey(
        BaseSchedule,
        on_delete=models.CASCADE,
        related_name='reservations'
    )

    player = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        related_name='reservations'
    )

    # La fecha específica del partido (no el día de semana genérico)
    date = models.DateField()

    status = models.CharField(
        max_length=15,
        choices=STATUS_CHOICES,
        default=STATUS_PENDING
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'reservations'
        # Un mismo horario no puede tener dos reservas en la misma fecha
        unique_together = ('schedule', 'date')

    def __str__(self):
        return f'{self.player} - {self.schedule} - {self.date}'


# ─────────────────────────────────────────────
#  RESEÑA
#  Un jugador puede dejar una reseña solo si su reserva está finalizada.
#  OneToOne con Reserva: una reserva = máximo una reseña.
# ─────────────────────────────────────────────

class Review(models.Model):

    # OneToOneField: una reserva solo puede tener una reseña
    review = models.OneToOneField(
        Reservation,
        on_delete=models.CASCADE,
        related_name='review'
    )

    rating = models.IntegerField()  # del 1 al 5, se valida en el serializer
    comment = models.TextField(blank=True)
    published_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'reviews'

    def __str__(self):
        return f'Reseña de {self.reservation.player} - {self.rating} estrellas'


# ─────────────────────────────────────────────
#  FAVORITO
#  Un jugador puede marcar complejos como favoritos.
#  unique_together evita que el mismo jugador marque dos veces el mismo complejo.
# ─────────────────────────────────────────────

class Favorite(models.Model):

    player = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        related_name='favorites'
    )

    facility = models.ForeignKey(
        Facility,
        on_delete=models.CASCADE,
        related_name='favorites'
    )

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'favorites'
        # Un jugador no puede marcar el mismo complejo dos veces
        unique_together = ('player', 'facility')

    def __str__(self):
        return f'{self.player} ♥ {self.facility}'