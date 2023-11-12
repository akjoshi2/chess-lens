"""This module works with the chess-piece dataset."""


import csv
import functools
import os
import shutil
from random import shuffle

import pandas as pd

from lc2fen.fen import PIECE_TYPES


PIECES_TO_CLASSNUM = {
    "_": 0,
    "b": 1,
    "k": 2,
    "n": 3,
    "p": 4,
    "q": 5,
    "r": 6,
    "B": 7,
    "K": 8,
    "N": 9,
    "P": 10,
    "Q": 11,
    "R": 12,
}

def split_dataset(dataset_dir, train_dir, validation_dir, train_perc=0.8):
    shutil.rmtree(train_dir)
    shutil.rmtree(validation_dir)

    os.mkdir(train_dir)
    os.mkdir(validation_dir)
    for piece in PIECES_TO_CLASSNUM.keys():
        os.mkdir(train_dir + "/"+piece+"/")
        os.mkdir(validation_dir + "/"+piece+"/")

    dirs = [
        d for d in os.listdir(dataset_dir)
        if os.path.isdir(os.path.join(dataset_dir, d))
    ]
    for dir in dirs:
        files = os.listdir(os.path.join(dataset_dir, dir))
        num_train_files = len(files) * train_perc
        for i, file in enumerate(files):
            path = os.path.join(dataset_dir, dir, file)
            if os.path.isfile(path):
                if i < num_train_files:
                    newpath = os.path.join(train_dir, dir, file)
                else:
                    newpath = os.path.join(validation_dir, dir, file)
                shutil.copy(path, newpath)
