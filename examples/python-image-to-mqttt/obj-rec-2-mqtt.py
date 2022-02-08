#!/usr/bin/env python3

# import device_patches       # Device specific patches for Jetson Nano (needs to be before importing cv2)

import cv2
import os
import paho.mqtt.client as mqtt
import sys, getopt
import time
from edge_impulse_linux.image import ImageImpulseRunner


def now():
    return round(time.time() * 1000)


def get_webcams():
    for port in range(5):
        video_device = f'/dev/video{port}'
        print(f"Looking for a camera {video_device}")
        camera = cv2.VideoCapture(port)
        if camera.isOpened():
            ret = camera.read()[0]
            if ret:
                backendName = camera.getBackendName()
                w = camera.get(3)
                h = camera.get(4)
                print("Camera %s (%s x %s) found in port %s " %(backendName,h,w, port))

                camera.release()
                return video_device
            camera.release()
    return None


def helper():
    print('./obj-rec-2-mqtt.py <path_to_model.eim> <fps> <video device path. uses the 1st available, if not provided>')


def main(argv):
    try:
        opts, args = getopt.getopt(argv, "h", ["--help"])
    except getopt.GetoptError:
        helper()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            helper()
            sys.exit()

    if len(args) == 0:
        help()
        sys.exit(2)

    model = args[0]

    dir_path = os.path.dirname(os.path.realpath(__file__))
    modelfile = os.path.join(dir_path, model)

    broker_address = "data-gateway"
    client = mqtt.Client("P1")
    client.connect(broker_address)

    with ImageImpulseRunner(modelfile) as runner:
        try:
            model_info = runner.init()
            print('Loaded runner for "' + model_info['project']['owner'] + ' / ' + model_info['project']['name'] + '"')
            # labels = model_info['model_parameters']['labels']
            if len(args) >= 2:
                videoCaptureDeviceId = int(args[1])
            else:
                videoCaptureDeviceId = get_webcams()
                if not videoCaptureDeviceId:
                    raise Exception('Cannot find any webcams')

            camera = cv2.VideoCapture(videoCaptureDeviceId)
            ret = camera.read()[0]
            if ret:
                backendName = camera.getBackendName()
                w = camera.get(3)
                h = camera.get(4)
                print("Camera %s (%s x %s) from %s selected." %(backendName,h,w, videoCaptureDeviceId))
                camera.release()
            else:
                raise Exception("Couldn't initialize selected camera.")

            for res, img in runner.classifier(videoCaptureDeviceId):
                if "bounding_boxes" in res["result"].keys():
                    print('Found %d bounding boxes (%d ms.)' % (len(res["result"]["bounding_boxes"]), res['timing']['dsp'] + res['timing']['classification']))
                    for bb in res["result"]["bounding_boxes"]:
                        msg = f"{bb['label']} ({bb['value']}): x={bb['x']} y={bb['y']} w={bb['width']} h={bb['height']}'
                        print(f'\t{msg}')
                        client.publish("demo", msg)
                        # img = cv2.rectangle(img, (bb['x'], bb['y']), (bb['x'] + bb['width'], bb['y'] + bb['height']), (255, 0, 0), 1)

        finally:
            if runner:
                runner.stop()
            if client:
                client.disconnect()


if __name__ == "__main__":
    main(sys.argv[1:])