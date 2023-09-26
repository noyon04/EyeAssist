from flask import Flask, request, jsonify
import cv2
import numpy as np
import glob
import os
import random
from tensorflow.lite.python.interpreter import Interpreter

app = Flask(__name__)

@app.route('/detect_objects', methods=['POST'])


def tflite_detect_image(modelpath, image, lblpath, min_conf=0.5):
    # Load the label map into memory
    with open(lblpath, 'r') as f:
        labels = [line.strip() for line in f.readlines()]

    # Load the Tensorflow Lite model into memory
    interpreter = Interpreter(model_path=modelpath)
    interpreter.allocate_tensors()

    # Get model details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    height = input_details[0]['shape'][1]
    width = input_details[0]['shape'][2]

    float_input = (input_details[0]['dtype'] == np.float32)
    input_mean = 127.5
    input_std = 127.5

    # Process image and resize to expected shape [1xHxWx3]
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    imH, imW, _ = image.shape
    image_resized = cv2.resize(image_rgb, (width, height))
    input_data = np.expand_dims(image_resized, axis=0)

    # Normalize pixel values if using a floating model (i.e. if model is non-quantized)
    if float_input:
        input_data = (np.float32(input_data) - input_mean) / input_std

    # Perform the actual detection by running the model with the image as input
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()

    # Retrieve detection results
    boxes = interpreter.get_tensor(output_details[1]['index'])[0]  # Bounding box coordinates of detected objects
    classes = interpreter.get_tensor(output_details[3]['index'])[0]  # Class index of detected objects
    scores = interpreter.get_tensor(output_details[0]['index'])[0]  # Confidence of detected objects

    detections = []

    # Loop over all detections and save detection data if confidence is above minimum threshold
    for i in range(len(scores)):
        if (scores[i] > min_conf) and (scores[i] <= 1.0):
            object_name = labels[int(classes[i])]  # Look up object name from "labels" array using class index
            detections.append({'object_name': object_name, 'confidence': scores[i]})

    return detections

def detect_objects():
    modelpath = 'detect_quant.tflite'
    lblpath = 'money_labelmap.txt'

    # Assuming you send the image as a file in the request
    image = request.files['image'].read()
    image = cv2.imdecode(np.frombuffer(image, np.uint8), cv2.IMREAD_UNCHANGED)
    
    results = tflite_detect_image(modelpath, image, lblpath)  # Using the modified tflite_detect_image function
    
    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
