from flask import Flask, request, send_file
import cv2
import numpy as np
import tempfile
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


@app.route('/process', methods=['POST'])
def process_image():
    operation = request.form['operation']
    file = request.files['image']

    npimg = np.frombuffer(file.read(), np.uint8)
    img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    if operation == 'Edge Detection':
        output = cv2.Canny(gray, 100, 200)
    elif operation == 'Histogram Equalization':
        output = cv2.equalizeHist(gray)
    elif operation == 'Thresholding':
        _, output = cv2.threshold(gray, 127, 255, cv2.THRESH_BINARY)
    elif operation == 'Erosion':
        kernel = np.ones((5,5), np.uint8)
        output = cv2.erode(gray, kernel, iterations=1)
    elif operation == 'Dilation':
        kernel = np.ones((5,5), np.uint8)
        output = cv2.dilate(gray, kernel, iterations=1)
    elif operation == 'Noise Removal':
        output = cv2.fastNlMeansDenoising(gray, None, 30, 7, 21)
    else:
        return "Unknown operation", 400

    temp = tempfile.NamedTemporaryFile(delete=False, suffix='.png')
    cv2.imwrite(temp.name, output)

    return send_file(temp.name, mimetype='image/png')

if __name__ == '__main__':
    app.run(debug=True)
