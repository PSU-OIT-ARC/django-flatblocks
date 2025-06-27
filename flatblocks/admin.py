from django.contrib import admin


class FlatBlockAdmin(admin.ModelAdmin):
    ordering = [
        "slug",
    ]
    list_display = ("slug", "header")
    search_fields = ("slug", "header", "content")
