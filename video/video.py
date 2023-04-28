#!/usr/bin/env python3

"""
Ports:
    5000 - video stream
    5001 - video streamer is listening for commands
    5002 - godot is listening for commands
"""

import cv2, time
from threading import Thread, Lock
from flask import Flask, Response
from socket import socket, timeout, AF_INET, SOCK_DGRAM


use_camera = True

controller_sock = None
tello_video = None



def _wait_for_message(sock, command, reply):

    while True:
        try:
            sock.sendto(command.encode("ascii"), ("0.0.0.0", 5002))
            message = sock.recv(128)
            if message.decode() != reply:
                time.sleep(1)
                continue
        except timeout:
            continue
        break



def _get_frames(tello):
    while True:
        success, frame = tello.cap.read()  # read the camera frame
        if not success:
            continue
        else:
            ret, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()
            with tello.lock:
                tello.frame = frame


class TelloVideo(object):
    VS_UDP_IP = '0.0.0.0'
    VS_UDP_PORT = 11111

    def __init__(self, webcam=False):
        self.frame = None
        self.lock = Lock()
        if webcam:
            self.cap = cv2.VideoCapture(0)
        else:
            address_schema = 'udp://@{ip}:{port}'  # + '?overrun_nonfatal=1&fifo_size=5000'
            address = address_schema.format(ip=self.VS_UDP_IP, port=self.VS_UDP_PORT)
            self.cap = cv2.VideoCapture(address)
            self.cap.open(address)

        self.thread = Thread(target=_get_frames, args=(self,), daemon=True)
        self.thread.start()

    def generator(self):
        while True:
            if self.frame:
                yield b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' + self.frame + b'\r\n'


app = Flask(__name__)


@app.route('/video_feed')
def video_feed():
    return Response(tello_video.generator(), mimetype='multipart/x-mixed-replace; boundary=frame')


controller_sock = socket(AF_INET, SOCK_DGRAM)
controller_sock.bind(('0.0.0.0', 5001))
controller_sock.settimeout(1)

# tell controller to turn on stream
# wait for controller to successfully turn on stream

print("turning on stream...")
_wait_for_message(controller_sock, "streamon", "stream=1")

# start retrieving video
print("Video streaming started")
tello_video = TelloVideo(webcam=use_camera)
_wait_for_message(controller_sock, "videoon", "video=1")

if __name__ == "__main__":
    app.run(port=5000, debug=True)
