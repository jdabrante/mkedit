from django.urls import path

from . import views

app_name = 'documents'

urlpatterns = [
    path('', views.home, name='home'),
    path('<uuid:docref>/edit/', views.edit_document, name='edit_document'),
    path('<uuid:docref>/', views.render_document, name='render_document'),
]
