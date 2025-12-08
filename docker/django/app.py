import os
import django
from django.conf import settings

if not settings.configured:
    settings.configure(
        DEBUG=True,
        DATABASES={
            'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': ':memory:',
            }
        },
        INSTALLED_APPS=[
            'django.contrib.contenttypes',
            'django.contrib.auth',
        ]
    )
    django.setup()

from django.http import JsonResponse
from django.views import View
from django.urls import path
from django.core.wsgi import get_wsgi_application

class HealthView(View):
    def get(self, request):
        return JsonResponse({'status': 'healthy'})

urlpatterns = [
    path('health/', HealthView.as_view()),
]

application = get_wsgi_application()
