#!/usr/bin/env python3

import cv2
import hashlib
import hmac
import json
import os
import requests
import time
from threading import Event


INGESTION_API = 'https://ingestion.edgeimpulse.com'

video_device = os.getenv('VIDEO_DEVICE', '/dev/video0')
assert os.path.exists(video_device), f'Cannot find video device {video_device}'

ei_api_key = os.environ['EDGE_IMPULSE_API_KEY']
ei_hmac_key = os.environ['EDGE_IMPULSE_HMAC_KEY']

label_name = os.getenv('LABEL_NAME_IDENTIFIER', 'nuvlabox-ei-collector')

interval = int(os.getenv('COLLECTION_INTERVAL', '10'))


def generate_metadata(image_file):
    with open(image_file, 'rb') as ifile:
        image = ifile.read()
    img_length = len(image)

    hmac_img = hmac.new(ei_hmac_key.encode(), image, hashlib.sha256)
    empty_signature = '0' * 64

    data = {
        'protected': {
            'ver': 'v1',
            'alg': 'HS256',
        },
        'signature': empty_signature,
        'payload': {
            'device_type': 'EDGE_IMPULSE_UPLOADER',
            'interval_ms': 0,
            'sensors': [{ 'name': 'image', 'units': 'rgba' }],
            'values': [
                f'Ref-BINARY-image/jpeg ({img_length} bytes) {hmac_img.hexdigest()}'
            ]
        }
    }

    encoded = json.dumps(data)
    hmac_metadata = hmac.new(ei_hmac_key.encode(), encoded.encode(), hashlib.sha256)
    signature = hmac_metadata.hexdigest()

    data['signature'] = signature

    metadata_file = 'metadata.json'
    with open(metadata_file, 'w') as md:
        md.write(json.dumps(data))

    return metadata_file


cap = cv2.VideoCapture("/dev/video0")
ret,frame = cap.read()
e = Event()
headers = {
    'x-api-key': ei_api_key,
    'x-label': label_name
}

while True:
    start = time.time()
    img_name = f'{label_name}_{int(start)}.jpg'
    cv2.imwrite(img_name,frame)

    metadata_file = generate_metadata(img_name)

    headers['x-file-name'] = img_name
    files = {metadata_file: (metadata_file, open(metadata_file), 'application/json'),
             img_name: (img_name, open(img_name, "rb"), 'image/jpeg')}

    r = requests.post(f'{INGESTION_API}/api/training/data',
                      headers=headers,
                      files=files
                      )

    try:
        os.remove(img_name)
    except:
        # not a reason to stop
        pass

    end = time.time()
    delta = end - start
    e.wait(timeout=interval-delta)

# cap.release()
