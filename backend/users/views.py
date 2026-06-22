from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from rest_framework_simplejwt.tokens import RefreshToken
import bcrypt

from .models import User
from .serializers import UserSerializer


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────

def generar_token(user):
    """Genera un JWT con datos del usuario en el payload."""
    refresh = RefreshToken.for_user(user)
    # Eliminamos user_id genérico y ponemos nuestros campos
    del refresh.payload['user_id']
    refresh.payload['id'] = user.id
    refresh.payload['name'] = user.name
    refresh.payload['lastname'] = user.lastname
    refresh.payload['role'] = user.role
    return refresh

def build_user_response(user):
    """Arma el diccionario de respuesta estándar para un usuario."""
    return {
        'id': user.id,
        'name': user.name,
        'lastname': user.lastname,
        'email': user.email,
        'phone': user.phone,
        'image': user.image,
        'role': user.role,
        'notification_token': user.notification_token,
    }


 
# ─────────────────────────────────────────────
#  REGISTRO
#  POST /api/register/
#  Body: { name, email, password, role }
# ─────────────────────────────────────────────
 


@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    try:
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            
            refresh = generar_token(user)
            access_token = str(refresh.access_token)
            
            return Response(
                {
                    'user': build_user_response(user),
                    'token': 'Bearer' + access_token
                }, 
                status=status.HTTP_201_CREATED
                )
        errores = []
        for field, errors in serializer.errors.items():
            for error in errors:
                errores.append(f'{field}: {error}')
        return Response(
            {'message': errores}, 
            status=status.HTTP_400_BAD_REQUEST
            )
    except Exception as e:
        return Response(
            {'message': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )



# ─────────────────────────────────────────────
#  LOGIN
#  POST /api/login/
#  Body: { email, password }
# ─────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response(
            {'message': "Email y contraseña son obligatorios"}, 
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        user = User.objects.get(email = email)

    except User.DoesNotExist:
        return Response(
            {'message':'Email o contraseña incorrectos'}, 
            status=status.HTTP_401_UNAUTHORIZED
        )


    if bcrypt.checkpw(
        password.encode('utf-8'),
        user.password.encode('utf-8')
    ):
        refresh = generar_token(user)
        access_token = str(refresh.access_token)
        
        return Response(
            {
                'user': build_user_response(user),
                'token': 'Bearer' + access_token
            },
            status=status.HTTP_200_OK
        )

    else:
        return Response(
            {'message':'Email o contraseña incorrectos'}, 
            status=status.HTTP_401_UNAUTHORIZED
        )

 
# ─────────────────────────────────────────────
#  OBTENER PERFIL
#  GET /api/usuario/<id>/
#  Requiere token JWT
# ─────────────────────────────────────────────
 
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user(request, id):
    try:
        user = User.objects.get(id = id)
    except User.DoesNotExist:
        return Response(
            {'message': 'Usuario no encontrado'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    return Response(
        {'user': build_user_response(user)},
        status=status.HTTP_200_OK
    )

# ─────────────────────────────────────────────
#  ACTUALIZAR PERFIL
#  PATCH /api/usuario/<id>/
#  Requiere token JWT
#  Body: { nombre?, apellido?, telefono? }
# ─────────────────────────────────────────────

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_user(request, id):
    # Solo el propio usuario puede actualizar su perfil
    if str(request.user.id) != str(id):
        return Response(
            {'message': 'No tenés permiso para modificar este usuario'},
            status=status.HTTP_403_FORBIDDEN
        )
 
    try:
        user = User.objects.get(id=id)
    except User.DoesNotExist:
        return Response(
            {'message': 'Usuario no encontrado'},
            status=status.HTTP_404_NOT_FOUND
        )
 
    serializer = UserSerializer(
        user,
        data=request.data,
        partial=True  # permite actualizar solo algunos campos
    )
 
    if serializer.is_valid():
        serializer.save()
        return Response(
            {'user': build_user_response(user)},
            status=status.HTTP_200_OK
        )
 
    return Response(
        {'message': serializer.errors},
        status=status.HTTP_400_BAD_REQUEST
    )