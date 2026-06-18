from rest_framework import serializers
from .models import User
import bcrypt;

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User 
        fields = ['id', 'name', 'email', 'image', 'password', 'notification_token', 'role', 'created_at']
        extra_kwargs={
            # No muestra la contraseña en el JSON
            'password':{'write_only':True},
            # Campos no obligatorios
            'notification_token': {'required': False}
        }

    def create(self, validated_data):
        ## para encriptar password
        raw_password = validated_data.pop('password')
        hashed_password = bcrypt.hashpw(raw_password.encode('utf-8'), bcrypt.gensalt())
        validated_data['password']=hashed_password.decode('utf-8')

        return User.objects.create(**validated_data)