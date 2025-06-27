from django.forms import ModelForm
from django.apps import apps
from django.conf import settings


class FlatBlockForm(ModelForm):
    class Meta:
        model = apps.get_model(settings.FLATBLOCKS_MODEL)
        exclude = ("slug",)
