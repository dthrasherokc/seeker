#!/usr/bin/env python3
import requests
import uuid
import sys
import re
import builtins

def downloadImageFromUrl(url, path):
    if not url.startswith('http'):
        return None, "Invalid URL"
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an HTTPError for bad responses
        img_data = response.content
        fPath = f"{path}/{uuid.uuid1()}.jpg"
        with open(fPath, 'wb') as handler:
            handler.write(img_data)
        return fPath, "Download successful"
    except requests.RequestException as e:
        return None, str(e)

def print(ftext, **args):
    clean_ftext = re.sub('\33\[\d+m', ' ', ftext)
    if sys.stdout.isatty():
        builtins.print(ftext, flush=True, **args)
    else:
        builtins.print(clean_ftext, flush=True, **args)

# Precompile the regex for ANSI escape codes
ansi_escape = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]')
