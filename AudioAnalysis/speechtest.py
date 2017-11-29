import numpy as np
import sys
from scipy.io import wavfile as wav
from matplotlib import pyplot as plt

WAVE_INPUT_FILENAME = sys.argv[1]
WAVE_ATTACK = './wav_samples/attack_'+WAVE_INPUT_FILENAME+'.wav'
WAVE_NORMAL = './wav_samples/normal_'+WAVE_INPUT_FILENAME+'.wav'
WAVE_NORMAL_COMPUTER = './wav_samples/normal_'+WAVE_INPUT_FILENAME+'_computer.wav'

#samfreq, sound = wav.read(WAVE_INPUT_FILENAME)
_, sound_attack = wav.read(WAVE_ATTACK)
##_, sound_normal = wav.read(WAVE_NORMAL)
##_, sound_normal_computer = wav.read(WAVE_NORMAL_COMPUTER)
#print ('freq: ', samfreq)
#print ('sound.shape: ', sound.shape)
#Change into -1 to 1 range
#print (sound)
#sound = sound/(2.**15)
#print (sound)
#timeArray = np.arange(0, sound.shape[0], 1.0)
#timeArray = timeArray / samfreq
#timeArray = timeArray * 1000 #scale to ms
#print (timeArray)
#print (timeArray.shape, sound.shape)
#_,background = wav.read('attack_sample.wav')
plt.plot(sound_attack, color='red')
#plt.plot(sound_normal, color='blue')
##plt.plot(sound_normal_computer, color='green')
#plt.ylim(-500,500)
plt.show()
