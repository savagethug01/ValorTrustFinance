#!/bin/sh
set -e

echo "🔄 Running Django migrations..."
python manage.py migrate --noinput

echo "📦 Collecting static files..."
python manage.py collectstatic --noinput

echo "👤 Creating superuser (if credentials provided)..."
python manage.py shell << END
import os
from django.contrib.auth import get_user_model

User = get_user_model()
username = os.environ.get('SUPERUSER_USERNAME')
email = os.environ.get('SUPERUSER_EMAIL')
password = os.environ.get('SUPERUSER_PASSWORD')

if username and email and password:
    if User.objects.filter(username=username).exists():
        User.objects.get(username=username).delete()
        print(f"🗑️ Existing superuser '{username}' deleted.")
    User.objects.create_superuser(username, email, password)
    print(f"✅ Superuser '{username}' created.")
else:
    print("⚠️ SUPERUSER_* env vars not set.")
END
