#!/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def log(*args, **kwargs):
    verbose = False
    if verbose:
        print("".join(map(str,args)), **kwargs)

def get_raw():
    data = pd.read_csv("../vision-enc-data/enc_vis.txt", sep=" ")
    # header: bot_id x y ang enc0 enc1 enc2 enc3
    data = data.drop("bot_id", axis=1)

    return data

def data_to_nn(df):
    pos_headers = ["x", "y"]
    enc_headers = ["enc0", "enc1", "enc2", "enc3"]

    df["ang"] = np.arctan2(np.sin(df["ang"]), np.cos(df["ang"])) / (2*np.pi)

    for h in pos_headers:
        df[h] = df[h] / 4000

    for h in enc_headers:
        df[h] = df[h] / 3000

    return df

def nn_to_data(np_array):
    df = pd.DataFrame(np_array, columns=["x","y","ang"])

    pos_headers = ["x", "y"]

    for h in pos_headers:
        df[h] = df[h] * 4000

    #  df["ang"] = df["ang"] * 2 * np.pi

    return df

def get_data(frame_delay=6, window_size=3):
    data = pd.read_csv("../vision-enc-data/enc_vis.txt", sep=" ")
    # header: bot_id x y ang enc0 enc1 enc2 enc3
    data = data.drop("bot_id", axis=1)

    data = data_to_nn(data)

    x_data = []
    y_data = []

    # Data input to LSTM is 3d, need features * window_size * sample_count
    for i in range(0, len(data) - window_size - frame_delay):
        log("--------------------------------------------------------------------------------")
        log("Processing row {}".format(i))

        # go from i-window_size to i
        x = data.iloc[i:i+window_size]    

        # time is i+window_size

        # grab only x, y, ang fields from the dataframe
        y = np.split(data, [3], axis=1)[0].iloc[i+window_size+frame_delay]

        x_data.append(x)
        y_data.append(y)

        log("X data")
        log(x)
        log("Y_data")
        log(y)
        log("--------------------------------------------------------------------------------")
        log()

    return x_data, y_data
