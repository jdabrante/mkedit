from django.forms import ModelForm

from .models import Document


class EditDocumentForm(ModelForm):
    class Meta:
        model = Document
        fields = ['title', 'contents']
