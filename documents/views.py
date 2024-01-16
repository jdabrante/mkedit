import markdown
from django.contrib import messages
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.http import require_http_methods

from .forms import EditDocumentForm
from .models import Document


def home(request):
    new_document = Document()
    new_document.save()
    return redirect(new_document.get_absolute_url())


# return redirect('wwdwd:dwwwdw', args=[document.ref])


@require_http_methods(['GET', 'POST'])
def edit_document(request, docref):
    document = get_object_or_404(Document, ref=docref)
    if request.method == 'POST':
        form = EditDocumentForm(request.POST)
        if form.is_valid():
            new_title = form.cleaned_data['title']
            new_contents = form.cleaned_data['contents']
            document.title = new_title
            document.contents = new_contents
            document.save()
            messages.add_message(request, messages.SUCCESS, 'Document was successfully saved!')
        else:
            messages.add_message(request, messages.ERROR, 'There are errors in form!')
    else:
        form = EditDocumentForm(instance=document)
    return render(request, 'documents/edit.html', dict(form=form, doc=document))


def render_document(request, docref):
    document = get_object_or_404(Document, ref=docref)
    render_contents = markdown.markdown(document.contents, extensions=['extra'])
    return render(
        request, 'documents/render.html', dict(doc=document, render_contents=render_contents)
    )
