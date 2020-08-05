import os
import string
import random
import json
import requests
import numpy as np
import tensorflow as tf
import tensorflow.keras as keras
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import cv2
from flask import Flask, request, redirect, url_for, render_template
from flask_bootstrap import Bootstrap
import pyodbc
from datetime import datetime

# check version:
print("keras      {}".format(keras.__version__))
print("tensorflow {}".format(tf.__version__))

app = Flask(__name__)
Bootstrap(app)


"""
Connect to sql server
"""

# connect to SQL server
# make sure the local IP address has been added to Azure SQL server firewall
server = 'tcp:chestxai.database.windows.net,1433'
database = 'ChestXAI'
username = 'XXXXXXXX'
password = 'XXXXXXXX'  # Please contact ChestX.ai team to request the access

OriginalImageURL = ''
ModelChartURL = ''
ModelImageURL = ''
maxImageID = ''
OriginalFile = ''


"""
Model loading
"""

OUTPUT_DIR = 'static'

class_label = ['Atelectasis', 'Cardiomegaly', 'Consolidation',
               'Effusion', 'Infiltration', 'Mass', 'Nodule', 'Pleural_Thickening']
binary_label = ['No Finding', 'Diseases']

BINARY_MODEL = keras.models.load_model(
    '/var/www/ChestXai/xray/model_7_retrain.h5')
COVID_MODEL = keras.models.load_model(
    '/var/www/ChestXai/xray/model_21_nonCOVID.h5')
MULTICLASS_MODEL = keras.models.load_model('/var/www/ChestXai/xray/model_6.h5')


SIZE = 224
TOP_N_CLASSES = 5


"""
Functions for MS SQL query
"""

# SQL quary of image URL updates


def get_patient_info(cnxn, cursor):
    """
    The function of get_patient_info() is to retrieve the basic patient information for the labeling of modeling results and images 
    """

    # Connect to MS SQL server
    cnxn = cnxn
    cursor = cursor

    # Query patient information from SQL server
    cursor.execute("""select * from ChestXAI.dbo.xray_image 
                    where ImageID = (select MAX(ImageID) from ChestXAI.dbo.xray_image)
                """)
    row = cursor.fetchone()
    maxImageID = row.ImageID

    cursor.execute("""select A.* from ChestXAI.dbo.patient A 
                        join ChestXAI.dbo.xray_image B on A.PatientID = B.PatientID 
                    where ImageID = (select MAX(ImageID) from ChestXAI.dbo.xray_image)
                """)
    row = cursor.fetchone()
    FirstName = row.FirstName
    LastName = row.LastName
    TimeStamp = datetime.now()
    Birthday = row.BirthDate

    # Name the file output
    TimeStampParse = str(TimeStamp.year) + str(TimeStamp.month) + str(TimeStamp.day) + str(
        TimeStamp.day) + str(TimeStamp.hour) + str(TimeStamp.minute) + str(TimeStamp.second)
    OriginalFile = FirstName + LastName + \
        str(Birthday) + TimeStampParse + '.png'
    ModelChartFile = FirstName + LastName + \
        str(Birthday) + TimeStampParse + '_barchart.png'
    ModelImageFile = FirstName + LastName + \
        str(Birthday) + TimeStampParse + '_model.png'
    OriginalImageURL = 'https://storage-chestxai-cos-standard-p9t.s3.us-east.cloud-object-storage.appdomain.cloud/' + OriginalFile
    ModelChartURL = 'https://storage-chestxai-cos-standard-p9t.s3.us-east.cloud-object-storage.appdomain.cloud/' + ModelChartFile
    ModelImageURL = 'https://storage-chestxai-cos-standard-p9t.s3.us-east.cloud-object-storage.appdomain.cloud/' + ModelImageFile

    # Update the URL of originial image to SQL server
    cursor.execute("""UPDATE ChestXAI.dbo.xray_image set ImageURL = ?, OriginalFileName = ?, UpdatedDate = ? where ImageID = ?""",
                   OriginalImageURL, OriginalFile, datetime.now(), maxImageID)
    cnxn.commit()
    return maxImageID, ModelChartURL, OriginalImageURL, ModelImageURL, OriginalFile, ModelChartFile, ModelImageFile

# Unsert new record to model results


def model_result_update(cursor, maxImageID, ModelImageURL, OriginalImageURL, ModelChartURL, COVID_Prob, NORMAL_Condition, cnxn):
    cursor = cursor
    maxImageID = maxImageID
    ModelImageURL = ModelImageURL
    OriginalImageURL = OriginalImageURL
    ModelChartURL = ModelChartURL
    COVID_Prob = COVID_Prob
    NORMAL_Condition = NORMAL_Condition
    cnxn = cnxn
    cursor.execute("""Insert into ChestXAI.dbo.model_result 
                     (ImageID, ModelImageURL, OriginalImageURL, 
                      ModelChartURL, COVID19, CreatedBy, CreatedDate, Normal) 
                  Values (?, ?, ?,
                          ?, ?, ?, ?, ?)
               """,
                   maxImageID, ModelImageURL, OriginalImageURL, ModelChartURL, COVID_Prob, "Dr.Tuesday", datetime.now(), NORMAL_Condition)
    cnxn.commit()


"""
Main function for chest X-ray image prediction and heatmap generation
"""


def get_prediction(image_path, ModelChartFile, ModelImageFile):
    """
    The function is to perform the prediction of chest X-ray images and generate Grad-CAM heatmap
    """

    image_path = image_path
    ModelChartFile = ModelChartFile
    ModelImageFile = ModelImageFile
    test_image = tf.keras.preprocessing.image.load_img(
        image_path, target_size=(SIZE, SIZE))
    test_image = tf.keras.preprocessing.image.img_to_array(test_image)
    test_image = np.expand_dims(test_image, axis=0)

    # tier 1 prediction (predict normal or diseases)
    y_pred_binary = BINARY_MODEL.predict(test_image)

    # Enter if block if binary prediction is Normal
    if np.argmax(y_pred_binary[0]) == 1:

        # Order binary predictions in top descending probability
        class_idxs_sorted = np.argsort(y_pred_binary.flatten())[::-1]
        print('Normal')

        # Check dimensions for heatmap
        img = tf.keras.preprocessing.image.load_img(
            image_path, target_size=(224, 224))
        save_path = '/mnt/storage_chestxai/' + ModelImageFile
        img.save(save_path)

        local_save_path = '/var/www/ChestXai/static/' + ModelImageFile
        img.save(local_save_path)

        COVID19 = 0.0
        NORMAL = 1

        # Generate the horizontal bar chart of 'No Finding' and 'Diseases'
        fig = plt.figure(figsize=(5, 5))
        ax = fig.add_subplot(111)
        x = [binary_label[i] for i in class_idxs_sorted]
        y = [round(y_pred_binary.flatten()[i]*100, 3)
             for i in class_idxs_sorted]
        width = 0.2
        rects1 = ax.barh(np.arange(2), [y_pred_binary.flatten()[
                         i]*100 for i in class_idxs_sorted], width, color="#2874A6")
        hfont = {'fontname': 'serif'}
        ax.set_xlabel('Probability [%]', fontsize=15, **hfont)
        # ax.set_title('Top Predicted Diseases', fontsize=15)
        ax.set_yticks(np.arange(2))
        ax.invert_yaxis()
        ax.set_yticklabels([binary_label[i]
                            for i in class_idxs_sorted], fontsize=12, **hfont)
        for i, v in enumerate(y):
            ax.text(v + 5, i, str(v), color='#2874A6',
                    fontweight='bold', fontsize=12)
        # ax.legend()
        right_side = ax.spines["right"]
        right_side.set_visible(False)
        top_side = ax.spines["top"]
        top_side.set_visible(False)

        chart_path = '/mnt/storage_chestxai/' + ModelChartFile
        plt.savefig(chart_path, bbox_inches="tight", dpi=200)

        chart_path_local = '/var/www/ChestXai/static/' + ModelChartFile
        plt.savefig(chart_path_local, bbox_inches="tight", dpi=200)

    # Enter else block if binary prediction is Disease
    else:
        y_pred_multiclass = MULTICLASS_MODEL.predict(test_image)
        class_idxs_sorted = np.argsort(y_pred_multiclass.flatten())[::-1]
        class_idxs_sorted = class_idxs_sorted[:TOP_N_CLASSES]
        print('Diseases')
        print(class_idxs_sorted)

        # create horizontal bar chart of disease probabilities
        fig = plt.figure(figsize=(5, 5))
        ax = fig.add_subplot(111)
        x = [class_label[i] for i in class_idxs_sorted]
        y = [round(y_pred_multiclass.flatten()[i]*100, 3)
             for i in class_idxs_sorted]
        width = 0.6
        rects1 = ax.barh(np.arange(5), [y_pred_multiclass.flatten()[
                         i]*100 for i in class_idxs_sorted], width, color="#2874A6")
        hfont = {'fontname': 'serif'}
        ax.set_xlabel('Probability [%]', fontsize=15, **hfont)
        ax.set_yticks(np.arange(5))
        ax.invert_yaxis()
        ax.set_yticklabels([class_label[i]
                            for i in class_idxs_sorted], fontsize=12, **hfont)
        for i, v in enumerate(y):
            ax.text(v + 5, i, str(v), color='#2874A6',
                    fontweight='bold', fontsize=12)
        right_side = ax.spines["right"]
        right_side.set_visible(False)
        top_side = ax.spines["top"]
        top_side.set_visible(False)

        # save images to IBM cloud object storage
        chart_path = '/mnt/storage_chestxai/' + ModelChartFile
        plt.savefig(chart_path, bbox_inches="tight", dpi=200)

        chart_path_local = '/var/www/ChestXai/static/' + ModelChartFile
        plt.savefig(chart_path_local, bbox_inches="tight", dpi=200)

        # Part 2: COVID
        COVID_label = ['COVID', 'NON-COVID']
        y_pred_covid = COVID_MODEL.predict(test_image)
        covid_prob = y_pred_covid[0].tolist()
        covid_prob = round(covid_prob[0], 3)
        COVID19 = covid_prob
        NORMAL = 0

        # --------------------------------------------
        # Grad-CAM heatmap
        # Ref: https://keras.io/examples/vision/grad_cam/

        # Grab the last conv layer and specify classifier layers
        last_conv_layer_name = 'conv5_block16_concat'
        classifier_layer_names = ['bn', 'relu', 'flatten', 'dense']
        last_conv_layer = MULTICLASS_MODEL.get_layer(last_conv_layer_name)
        last_conv_layer_model = keras.Model(
            MULTICLASS_MODEL.inputs, last_conv_layer.output)
        classifier_input = keras.Input(shape=last_conv_layer.output.shape[1:])

        # classifier_input
        x = classifier_input
        for layer_name in classifier_layer_names:
            x = MULTICLASS_MODEL.get_layer(layer_name)(x)
        classifier_model = keras.Model(classifier_input, x)

        # Watch gradients change
        with tf.GradientTape() as tape:
            last_conv_layer_output = last_conv_layer_model(test_image)
            tape.watch(last_conv_layer_output)
            preds = classifier_model(last_conv_layer_output)
            top_pred_index = tf.argmax(preds[0])
            print(top_pred_index)
            top_class_channel = preds[:, 5]

        grads = tape.gradient(top_class_channel, last_conv_layer_output)

        pooled_grads = tf.reduce_mean(grads, axis=(0, 1, 2))

        last_conv_layer_output = last_conv_layer_output.numpy()[0]

        pooled_grads = pooled_grads.numpy()

        for i in range(pooled_grads.shape[-1]):
            last_conv_layer_output[:, :, i] *= pooled_grads[i]

        heatmap = np.mean(last_conv_layer_output, axis=-1)
        heatmap = np.maximum(heatmap, 0) / np.max(heatmap)
        print(heatmap)

        # Check dimensions for heatmap
        img = tf.keras.preprocessing.image.load_img(
            image_path, target_size=(224, 224))
        img = tf.keras.preprocessing.image.img_to_array(img)

        # Rescale heatmap to a range 0-255
        heatmap = np.uint8(255 * heatmap)

        # Use jet colormap to colorize heatmap
        jet = cm.get_cmap("jet")

        # Use RGB values of the colormap
        jet_colors = jet(np.arange(256))[:, :3]
        jet_heatmap = jet_colors[heatmap]

        # Create an image with RGB colorized heatmap
        jet_heatmap = keras.preprocessing.image.array_to_img(jet_heatmap)
        jet_heatmap = jet_heatmap.resize((img.shape[1], img.shape[0]))
        jet_heatmap = keras.preprocessing.image.img_to_array(jet_heatmap)

        # Superimpose the heatmap on original image
        superimposed_img = jet_heatmap * 0.4 + img
        superimposed_img = keras.preprocessing.image.array_to_img(
            superimposed_img)

        # Save the superimposed image to IBM object storage
        save_path = '/mnt/storage_chestxai/' + ModelImageFile
        superimposed_img.save(save_path)

        local_save_path = '/var/www/ChestXai/static/' + ModelImageFile
        superimposed_img.save(local_save_path)

    return COVID19, NORMAL


"""
Flask-RESTful API
"""


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        uploaded_file = request.files['loadfile']
        if uploaded_file.filename != '':
            print('Successfully Get X-ray Image')
            cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=' +
                                  server+';DATABASE='+database+';UID='+username+';PWD=' + password)
            cursor = cnxn.cursor()
            if uploaded_file.filename[-3:] in ['jpg', 'png', 'jpeg']:
                maxImageID, ModelChartURL, OriginalImageURL, ModelImageURL, OriginalFile, ModelChartFile, ModelImageFile = get_patient_info(
                    cnxn, cursor)
                image_path = os.path.join(OUTPUT_DIR, OriginalFile)
                uploaded_file.save(image_path)
                result = {'path_to_image': OriginalImageURL}
                COVID_Prob, NORMAL_Condition = get_prediction(
                    image_path, ModelChartFile, ModelImageFile)
                model_result_update(cursor, maxImageID, ModelImageURL, OriginalImageURL,
                                    ModelChartURL, COVID_Prob, NORMAL_Condition, cnxn)
                img = cv2.imread(image_path)
                img_resize = cv2.resize(img, (512, 512))
                file_name = '/mnt/storage_chestxai/' + OriginalFile
                cv2.imwrite(file_name, img_resize)
                cursor.close()
                cnxn.close()
                return render_template('show.html', result=result)
    return render_template('index.html')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
