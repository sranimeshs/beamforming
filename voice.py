import logging
import sys
import click
import csv
import os
import wave
import time
import shutil
import subprocess

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from brainoft import voice_agent
from brainoft.utils.vault import setup_google_cred
from brainoft.voice import save
from brainoft.voice.hotword_detector import HotwordDetector
from brainoft.voice.settings import SAMPLE_RATE, CASPAR_TRANSCRIPTIONS
from brain_constants import BotFilePaths
from sklearn.metrics import precision_recall_fscore_support


from brainoft.logger.log_setup import setup_logging

logger = logging.getLogger(__name__)


BLOCK_SIZE = 4000
CHUNK = 1024
ENABLE_DING_REMOVAL = False


def mock_get_alsa_device_name(arg1):
    return 'TEST_DEVICE'


def mock_get_user_area(arg1):
    return None


def mock_is_device_available(arg):
    return True


@click.group()
def cli():
    """
    This script provides tools required for debugging and testing related to voice.
    """
    pass


def wavefile_generator(filename):
    wavfile = wave.open(filename, "r")
    length = wavfile.getnframes()
    i = 0
    while i < length:
        block = wavfile.readframes(min(BLOCK_SIZE, length - i))
        i += BLOCK_SIZE
        yield block
    wavfile.close()


@click.command(help="Compute the hotword accuracy of a hotword detector model given a set of callword samples.")
@click.option('--data', type=str, help="Absolute path to the data folder containing all the samples to "
                                       "run the script on")
@click.option('--labelfile', type=str, help="File containing the ground truth labels of the file")
@click.option('--sensitivity', type=float, help="Sensitivity of hotword detector to be used", default=0.6)
def hotword_accuracy(data, labelfile, sensitivity):
    res = compute_hotword_accuracy(data, labelfile, sensitivity)
    print('ACCURACY, %s, %s, %s, %s' % (sensitivity, res[0][1], res[1][1], res[2][1]))


def compute_hotword_accuracy(data, labelfile, sensitivity):
    actual_label = []
    predicted_label = []
    detector = HotwordDetector(BotFilePaths.model_file('hotword_detector', "caspar-08-18-2017-v2.umdl"),
                               sensitivity=sensitivity)
    results_csvfile = open('accuracy_results.csv', "w")
    results_csvfile_writer = csv.writer(results_csvfile)
    with open(labelfile, "r") as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            result = False
            for block in wavefile_generator(os.path.join(data, row[0])):
                callword_detection = detector.detect_hotword(block)
                if callword_detection["ans"] > 0:
                    result = True
                    break
            predicted_label.append(str(result))
            actual_label.append(row[1])
            results_csvfile_writer.writerow([row[0], row[1], str(result), callword_detection["signal_strength"],
                                             callword_detection["bandpass_op"]])
            detector.reset_detector()
    results_csvfile.close()
    return precision_recall_fscore_support(actual_label, predicted_label)


@click.command(help="given a wavfile logs all the timestamps at which callword was detected")
@click.option('--data', type=str, help="Absolute path to the data folder containing all the samples to "
                                       "run the script on")
@click.option('--labelfile', type=str, help="File containing the ground truth labels of the file")
@click.option('--sensitivity', type=float, help="Sensitivity of hotword detector to be used", default=0.6)
def log_callword_timestamp(data, labelfile, sensitivity):
    detector = HotwordDetector(BotFilePaths.model_file('hotword_detector', "caspar-08-18-2017-v2.umdl"),
                               sensitivity=sensitivity)
    results_csvfile = open('log_callword_timestamp_{}.csv'.format(time.strftime("%H%M")), "w")
    results_csvfile_writer = csv.writer(results_csvfile)
    with open(labelfile, "r") as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            block_no = 0
            results_csvfile_writer.writerow([row[0]])
            for block in wavefile_generator(os.path.join(data, row[0])):
                callword_detection = detector.detect_hotword(block)
                if callword_detection["ans"] > 0:
                    results_csvfile_writer.writerow([block_no, callword_detection["signal_strength"],
                                                     callword_detection["bandpass_op"]])
                block_no += 1
            detector.reset_detector()
    results_csvfile.close()


@click.command(help="Compute hotword accuracy using google API. Sends all the wavfiles to Google ASR and returns "
                    "callword detected if the transcription is Caspar")
@click.option('--data', type=str, help="Absolute path to the data folder containing all the samples to "
                                       "run the script on")
@click.option('--labelfile', type=str, help="File containing the ground truth labels of the file")
def compute_hotword_accuracy_google(data, labelfile):
    setup_google_cred("voice", force_overwrite=True)
    actual_label = []
    predicted_label = []
    results_csvfile = open('accuracy_results_google_{}.csv'.format(time.strftime("%H%M")), "w")
    results_csvfile_writer = csv.writer(results_csvfile)
    with open(labelfile, "r") as csvfile:
        reader = csv.reader(csvfile)
        next(reader)
        for row in reader:
            result = False
            try:
                transcriptions = voice_agent.get_transcriptions_from_google(os.path.join(data, row[0]))
            except:
                continue
            used_transcription = ""
            if transcriptions:
                for t in transcriptions:
                    if t in CASPAR_TRANSCRIPTIONS:
                        result = True
                        used_transcription = t
                        break
            else:
                result = False
            predicted_label.append(str(result))
            actual_label.append(row[1])
            results_csvfile_writer.writerow([row[0], row[1], str(result), used_transcription])
    results_csvfile.close()
    return precision_recall_fscore_support(actual_label, predicted_label)


@click.command(help="Run google speech API on set of samples and write the results into a csv file.")
@click.option('--data_dir', type=str, help="Folder containing data samples to run the script on")
def run_google_service(data_dir):
    setup_google_cred("voice", force_overwrite=True)
    with open("results_{}.csv".format(time.strftime("%Y%m%d-%H%M%S")), "wb") as resultfile:
        csvwriter = csv.writer(resultfile)
        csvwriter.writerow(["filename", "sync responses", "stream responses"])
        for f in os.listdir(data_dir):
            try:
                if not f.endswith('wav'):
                    continue
                filename = os.path.join(data_dir, f)
                google_sync_response = voice_agent.get_transcriptions_from_google(filename)
                google_stream_response = voice_agent.run_google_filestream(filename)
                transcription1 = google_sync_response['transcription'] if google_sync_response else ""
                transcription2 = google_stream_response['transcription'] if google_stream_response else ""
                csvwriter.writerow([f, transcription1, transcription2])
            except:
                continue


@click.command(help="Remove the ding from the wavfile.")
@click.option('--data_dir', type=str, help="Folder containing data samples to run the script on")
def remove_ding_from_wav(data_dir):
    for f in os.listdir(data_dir):
        if not f.endswith('wav'):
            continue
        filename = os.path.join(data_dir, f)
        logger.debug("Filename: {}".format(filename))
        # Load the wavfile into the queue.
        voice_agent._get_alsa_device_name = mock_get_alsa_device_name
        voice_agent._get_user_area = mock_get_user_area
        voice_agent._is_device_available = mock_is_device_available
        watcher = voice_agent.CallwordWatcher(None, False)
        wavfile = wave.open(filename, 'r')
        length = wavfile.getnframes()
        block_size = SAMPLE_RATE / voice_agent.PERIOD_SIZE
        for i in xrange(0, length, block_size):
            watcher._mic_data.append(wavfile.readframes(block_size))
            if len(watcher._mic_data) == watcher._mic_data.maxlen:
                # unlike the live system, where the data is consumed as soon as its filled in the queue, we are
                # prefilling the queue with pre recorded wavfile. Only initial part of data is required and we don't
                # want to overflow the buffer here.
                break
        # Remove the ding from the queue
        watcher.remove_redundant_sound()
        # Save it back into another wavfile in modified directory.
        modified_file = save.WavFile('modified_{}'.format(f.split('.')[0]), framerate=SAMPLE_RATE)
        for e in watcher._mic_data:
            modified_file.write(e)
        for j in xrange(wavfile.tell(), length, block_size):
            modified_file.write(wavfile.readframes(block_size))
        modified_file.close()


@click.command(help="Tool to label hotword samples. You can label positive or negative sample and the gender of the "
                    "speaker. Complete information here: "
                    "https://brainoft.atlassian.net/wiki/display/EN/Labelling+Data")
@click.option('--data_dir', type=click.Path(exists=True, file_okay=False, dir_okay=True, resolve_path=True),
              default=os.getcwd(), help="Path of the directory from the root containing the audio samples")
@click.option('--ch', type=int, default=0, help="Channel ID from which the audio samples should be played")
@click.option('--labelfile', type=str, default="labels.txt", help="names of file in which labels should be generated")
def label_hotword_data(data_dir=os.getcwd(), ch=0, labelfile="labels.txt"):
    csv_file = open(labelfile, 'wb')
    writer = csv.writer(csv_file)
    writer.writerow(("filename", "positive", "gender"))
    for f in os.listdir(data_dir):
        if not f.endswith('.wav'):
            continue
        logger.debug(f)
        filename = os.path.join(data_dir, f)
        subprocess.call('paplay {}'.format(filename), shell=True, close_fds=True)
        label = raw_input()
        if label == 'pm':
            is_positive = True
            gender = 'M'
        elif label == 'pf':
            is_positive = True
            gender = 'F'
        elif label == 'p':
            is_positive = True
            gender = None
        elif label == 'r':
            is_positive = True
            gender = 'Repeat'
        else:
            is_positive = False
            gender = None
        writer.writerow((f, is_positive, gender))
        shutil.move(filename, os.path.join(data_dir, "labeled_samples", f))
    csv_file.close()

if __name__ == "__main__":
    setup_logging("voice_tools")
    cli.add_command(run_google_service)
    cli.add_command(hotword_accuracy)
    cli.add_command(remove_ding_from_wav)
    cli.add_command(label_hotword_data)
    cli.add_command(compute_hotword_accuracy_google)
    cli.add_command(log_callword_timestamp)
    cli()
