from django.conf import settings

AUTOCREATE_STATIC_BLOCKS = getattr(
    settings, "FLATBLOCKS_AUTOCREATE_STATIC_BLOCKS", False
)
FLATBLOCKS_MODEL = getattr(settings, "FLATBLOCKS_MODEL")
