import uuid

from django.db import models
from django.urls import reverse


class Document(models.Model):
    ref = models.UUIDField(unique=True, default=uuid.uuid4)
    title = models.CharField(max_length=256, default='✨ New markdown document')
    contents = models.TextField(blank=True, default='Hi there! This is **markdown** 👋')
    created = models.DateTimeField(auto_now=True)
    updated = models.DateTimeField(auto_now_add=True)

    def get_absolute_url(self):
        return reverse('documents:edit_document', args=[self.ref])

    def __str__(self):
        return str(self.ref)
