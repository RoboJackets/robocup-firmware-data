#!/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from keras.models import Sequential
from keras.layers import LSTM, Dense

from matplotlib import pyplot as plt
from matplotlib import animation

verbose = False

def log(*args, **kwargs):
    if verbose:
        print("".join(map(str,args)), **kwargs)

data = pd.read_csv("../vision-enc-data/enc_vis.txt", sep=" ")
data = data.drop("bot_id", axis=1)

# header: bot_id x y ang enc0 enc1 enc2 enc3

window_size = 3

x_data = []
y_data = []

# Data input to LSTM is 3d, need features * window_size * sample_count
for i in range(0, len(data) - window_size - 1):
    log("--------------------------------------------------------------------------------")
    log("Processing row {}".format(i))

    # go from i-window_size to i
    x = data.iloc[i:i+window_size]    

    # grab only x, y, ang fields from the dataframe
    y = np.split(data, [3], axis=1)[0].iloc[i+window_size]

    x_data.append(x)
    y_data.append(y)

    log("X data")
    log(x)
    log("Y_data")
    log(y)
    log("--------------------------------------------------------------------------------")
    log()

#  sec = data.iloc[0:0+window_size]

#  print(sec)

#  dfs = np.split(sec, [3], axis=1)

#  print(dfs[0])
#  print(dfs[1])

#  for i in range(0, data_len - window_size):
    #  data_section = data.iloc[i:i+window_size])
    #  #  data_section_x = data
    #  #  data_set.append(data.iloc[i:i+window_size])

#  data_dim = 7
#  timesteps = 10
#  #  num_classes = 10
#  batch_size = 32

#  # Expected input batch shape: (batch_size, timesteps, data_dim)
#  # Note that we have to provide the full batch_input_shape since the network is stateful.
#  # the sample of index i in batch k is the follow-up for the sample i in batch k-1.
#  model = Sequential()
#  model.add(LSTM(32, return_sequences=True, stateful=True,
               #  batch_input_shape=(batch_size, timesteps, data_dim)))
#  model.add(LSTM(32, return_sequences=True, stateful=True))
#  model.add(LSTM(32, stateful=True))
#  model.add(Dense(10, activation='softmax'))

#  model.compile(loss='categorical_crossentropy',
              #  optimizer='rmsprop',
              #  metrics=['accuracy'])

#  # Generate dummy training data
#  #  x_train = np.random.random((batch_size * 10, timesteps, data_dim))
#  #  y_train = np.random.random((batch_size * 10, num_classes))

#  #  # Generate dummy validation data
#  #  x_val = np.random.random((batch_size * 3, timesteps, data_dim))
#  #  y_val = np.random.random((batch_size * 3, num_classes))

#  model.fit(x_train, y_train,
          #  batch_size=batch_size, epochs=5, shuffle=False)
          #  #  validation_data=(x_val, y_val))

