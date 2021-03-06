# Audio Analysis

## Recording Samples

### Dependencies
Python 3.5+

Librosa 

matplotlib

numpy

### Recording
```bash
python record.py <attack/normal>_<filename.wav>
```

Example:
```bash
python record.py attack_alexa_how_are_you.wav
python record.py normal_alexa_how_are_you.wav
```

Audio sample will be stored in **wav_samples** folder

### Visualization
<a href=https://github.com/scanakci/DolphinAttack/blob/record/AudioAnalysis/Visualize.ipynb>Visualize.ipynb</a>

### Logistic Regresion Model
<a href=https://github.com/scanakci/DolphinAttack/blob/master/AudioAnalysis/SupervisedLearning.ipynb>SupervisedLearning.ipynb</a>
