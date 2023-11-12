"""This is the main program for converting board images into FENs."""


import argparse

# `sklearn` is required for Jetson (to avoid "cannot allocate memory in
# static TLS block" error)
import sklearn
from keras.applications.mobilenet_v2 import preprocess_input as prein_mobilenet
from lc2fen.predict_board import predict_board_keras



ACTIVATE_KERAS = True
MODEL_PATH_KERAS = "cpmodels/models/MobileNetV2_0p5_last.h5"
IMG_SIZE_KERAS = 224
PRE_INPUT_KERAS = prein_mobilenet

def parse_arguments() -> tuple[str, str, str | None]:
    """Parse the script arguments and set the corresponding flags.

    :return: Path of the image or folder, location of the a1 square, and
    FEN string of the previous board position.
    """
    global ACTIVATE_KERAS, ACTIVATE_ONNX, ACTIVATE_TRT

    parser = argparse.ArgumentParser(
        description="Predicts board configuration(s) (FEN string(s)) from "
        "image(s)."
    )

    parser.add_argument(
        "path",
        help="Path to the image or folder you wish to predict the FEN(s) for",
    )
    parser.add_argument(
        "a1_pos",
        help="Location of the a1 square in the chessboard image(s) "
        "(B = bottom, T = top, R = right, L = left)",
        choices=["BL", "BR", "TL", "TR"],
    )
    parser.add_argument(
        "previous_fen",
        nargs="?",
        help="FEN string of the previous board position (if "
        "you are predicting the FEN for a single image and if "
        "the previous board position is known)",
    )

    inf_engine = parser.add_mutually_exclusive_group(required=True)
    inf_engine.add_argument(
        "-k", "--keras", help="run inference using Keras", action="store_true"
    )
    inf_engine.add_argument(
        "-o",
        "--onnx",
        help="run inference using ONNXRuntime",
        action="store_true",
    )
    inf_engine.add_argument(
        "-t", "--trt", help="run inference using TensorRT", action="store_true"
    )

    args = parser.parse_args()

    return args.path, args.a1_pos, args.previous_fen


def main():
    """Parse the arguments and print the predicted FEN."""
    path, a1_pos, previous_fen = parse_arguments()
    fen, _ = predict_board_keras(
        MODEL_PATH_KERAS,
        IMG_SIZE_KERAS,
        PRE_INPUT_KERAS,
        path,
        a1_pos,
        previous_fen=previous_fen,
    )
    print(fen)


if __name__ == "__main__":
    main()

def getBoardFen(image, previous_fen):
    a1_pos = "BR"
    fen, _ = predict_board_keras(
        MODEL_PATH_KERAS,
        IMG_SIZE_KERAS,
        PRE_INPUT_KERAS,
        image,
        a1_pos,
        previous_fen=previous_fen,
    )
    return fen