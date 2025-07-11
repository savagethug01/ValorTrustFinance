from django.http import HttpResponse
from django.shortcuts import redirect

from django.contrib import messages

def check_frozen(view_func):
    def wrapper(request, *args, **kwargs):
        if hasattr(request.user, 'userprofile') and request.user.userprofile.frozenState:
            messages.error(request, "Your account is frozen. You cannot perform this operation.")
            return redirect('account_frozen_page')  # Or any page explaining the freeze
        return view_func(request, *args, **kwargs)
    return wrapper

def unauthenticated_user(view_func):
    def wrapper_func(request, *args, **kwargs):
        if request.user.is_authenticated:
            return redirect('dashboard')
        else:
            return view_func(request, *args, **kwargs)

    return wrapper_func
