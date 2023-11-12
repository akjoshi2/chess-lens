"""This module is responsible for predicting board configurations."""


import glob
import os
import re
import shutil
import time

import cv2
import numpy as np
from keras.models import load_model
from keras.utils import load_img, img_to_array
import chess

from lc2fen.detectboard.detect_board import detect, compute_corners
from lc2fen.fen import (
    list_to_board,
    board_to_fen,
    compare_fen,
    is_light_square,
    fen_to_board,
    board_to_list,
)
from lc2fen.infer_pieces import infer_chess_pieces
from lc2fen.split_board import split_board_image_trivial


def load_image(image, img_size: int, preprocess_func) -> np.ndarray:
    """Load an image.

    This function loads an image from its path. It is intended to be
    used for loading piece images.

    :param img_path: Image path.

    :param img_size: Size of the input image. Example: `224`.

    :param preprocess_func: Preprocessing fuction for the input image.

    :return: Preprocessed image.
    """
    if(isinstance(image, str)):
        img = load_img(image, target_size=(img_size, img_size))
    else:
        img = image
    img_tensor = img_to_array(img)
    img_tensor = np.expand_dims(img_tensor, axis=0)
    return preprocess_func(img_tensor)


def predict_board_keras(
    model_path: str,
    img_size: int,
    pre_input,
    path="",
    a1_pos="",
    test=False,
    previous_fen: (str | None) = None,
) -> tuple[str, list[list[int]]] | None:
    model = load_model(model_path)

    def obtain_piece_probs_for_all_64_squares(
        pieces: list[str],
    ) -> list[list[float]]:
        predictions = []
        for piece in pieces:
            piece_img = load_image(piece, img_size, pre_input)
            predictions.append(model.predict(piece_img)[0])
        return predictions

    if test:
        test_predict_board(obtain_piece_probs_for_all_64_squares)
    else:
        if os.path.isdir(path):
            return continuous_predictions(
                path, a1_pos, obtain_piece_probs_for_all_64_squares
            )
        else:
            return predict_board(
                path,
                a1_pos,
                obtain_piece_probs_for_all_64_squares,
                previous_fen=previous_fen,
            )

def predict_board(
    board_path: str,
    a1_pos: str,
    obtain_piece_probs_for_all_64_squares,
    board_corners: (list[list[int]] | None) = None,
    previous_fen: (str | None) = None,
) -> tuple[str, list[list[int]]]:
    """Predict the FEN string from a chessboard image.

    :param board_path: Path to the chessboard image of interest.

        The path must have rw permission.

        Example: `"../predictions/board.jpg"`.

    :param a1_pos: Position of the a1 square of the chessboard image.

        This is the position of the a1 square (`"BL"`, `"BR"`, `"TL"`,
        or `"TR"`) corresponding to the chessboard image.

    :param obtain_piece_probs_for_all_64_squares: Path-to-prob function.

        This function takes as input a length-64 list of paths to
        chess-piece images and returns a length-64 list of the
        corresponding piece probabilities (each element of the list is a
        length-13 sublist that contains 13 piece probabilities).

        This parameter allows us to deploy different inference engines
        (Keras, ONNX, or TensorRT).

    :param board_corners: Length-4 list of coordinates of four corners.

        The 4 board corners are in the order of top left, top right,
        bottom right, and bottom left.

        If it is not `None` and the corner coordinates are accurate
        enough, the neural-network-based board-detection step is skipped
        (which means the total processing time is reduced).

    :param previous_fen: FEN string of the previous board position.

        If it is not `None`, it could significantly improve the accuracy
        of FEN prediction.

    :return: A pair formed by the predicted FEN string and the
    coordinates of the corners of the chessboard in the input image.
    """
    board_corners = detect_input_board(board_path, board_corners)
    pieces = obtain_individual_pieces(board_path)
    probs_with_no_indices = obtain_piece_probs_for_all_64_squares(pieces)
    if previous_fen is not None and not check_validity_of_fen(previous_fen):
        print(
            "Warning: the previous FEN is ignored because it is invalid for a "
            "standard physical chess set"
        )
        previous_fen = None
    predictions = infer_chess_pieces(
        probs_with_no_indices, a1_pos, previous_fen
    )

    board = list_to_board(predictions)
    fen = board_to_fen(board)

    return fen, board_corners


def continuous_predictions(
    path: str, a1_pos: str, obtain_piece_probs_for_all_64_squares
):
    """Predict FEN strings from chessboard images continuously.

    This function continuously monitors a folder and predicts the FEN
    strings for new jpg images added to the folder. The FEN string is
    printed out every time a prediction is completed. Note that this
    function does not return.

    :param path: Path to the folder that contains chessboard image(s).

        Example: '../predictions/'.

    :param a1_pos: Position of the a1 square of the chessboard image(s).

        This is the position of the a1 square (`"BL"`, `"BR"`, `"TL"`,
        or `"TR"`) corresponding to the chessboard image(s).

    :param obtain_piece_probs_for_all_64_squares: Path-to-prob function.

        This function takes as input a length-64 list of paths to
        chess-piece images and returns a length-64 list of the
        corresponding piece probabilities (each element of the list is a
        length-13 sublist that contains 13 piece probabilities).
    """
    if not os.path.isdir(path):
        raise ValueError("The input path must point to a folder")

    def natural_key(text):
        return [int(c) if c.isdigit() else c for c in re.split(r"(\d+)", text)]

    print("Done loading. Monitoring " + path)
    board_corners = None
    fen = None
    processed_board = False
    while True:
        for board_path in sorted(glob.glob(path + "*.jpg"), key=natural_key):
            fen, board_corners = predict_board(
                board_path,
                a1_pos,
                obtain_piece_probs_for_all_64_squares,
                board_corners,
                fen,
            )
            print(fen)
            processed_board = True
            os.remove(board_path)

        if not processed_board:
            time.sleep(0.1)


def test_predict_board(obtain_piece_probs_for_all_64_squares):
    """Test `predict_board()`.

    :param obtain_piece_probs_for_all_64_squares: Path-to-prob function.

        This function takes as input a length-64 list of paths to
        chess-piece images and returns a length-64 list of the
        corresponding piece probabilities (each element of the list is a
        length-13 sublist that contains 13 piece probabilities).
    """
    fens, a1_squares, previous_fens = read_correct_fen(
        os.path.join("predictions", "boards_with_previous.fen")
    )

    for i in range(5):
        fen = time_predict_board(
            os.path.join("predictions", "test" + str(i + 1) + ".jpg"),
            a1_squares[i],
            obtain_piece_probs_for_all_64_squares,
        )
        print_fen_comparison(
            "test" + str(i + 1) + ".jpg",
            fen,
            fens[i],
            False,
        )

        if previous_fens[i] is not None and not check_validity_of_fen(
            previous_fens[i]
        ):
            print(
                f"Warning: the previous FEN for test{i + 1}.jpg is ignored "
                "because it is invalid for a standard physical chess set\n"
            )
            previous_fens[i] = None

        if previous_fens[i] is not None:
            fen = time_predict_board(
                os.path.join("predictions", "test" + str(i + 1) + ".jpg"),
                a1_squares[i],
                obtain_piece_probs_for_all_64_squares,
                previous_fens[i],
            )
            print_fen_comparison(
                "test" + str(i + 1) + ".jpg", fen, fens[i], True
            )


def detect_input_board(
    board_path: str, board_corners: (list[list[int]] | None) = None
) -> list[list[int]]:
    """Detect the input board.

    This function takes as input a path to a chessboard image
    (e.g., "image.jpg") and stores the image that contains the detected
    chessboard in the "tmp" subfolder of the folder containing the board
    (e.g., "tmp/image.jpg").

    If the "tmp" folder already exists, the function deletes its
    contents. Otherwise, the function creates the "tmp" folder.

    :param board_path: Path to the chessboard image of interest.

        The path must have rw permission.

        Example: `"../predictions/board.jpg"`.

    :param board_corners: Length-4 list of coordinates of four corners.

        The 4 board corners are in the order of top left, top right,
        bottom right, and bottom left.

        If it is not `None` and the corner coordinates are accurate
        enough, the neural-network-based board-detection step is skipped
        (which means the total processing time is reduced).

    :return: Length-4 list of the (new) coordinates of the four board
    corners detected.
    """
    input_image = cv2.imread(board_path)
    head, tail = os.path.split(board_path)
    tmp_dir = os.path.join(head, "tmp/")
    if os.path.exists(tmp_dir):
        shutil.rmtree(tmp_dir)
    os.mkdir(tmp_dir)
    image_object = detect(
        input_image, os.path.join(head, "tmp", tail), board_corners
    )
    board_corners, _ = compute_corners(image_object)
    return board_corners


def obtain_individual_pieces(board_path: str) -> list[str]:
    """Obtain the individual pieces of a board.

    :param board_path: Path to the chessboard image of interest.

        The path must have rw permission.

        The image of the detected chessboard must be in the
        corresponding "tmp" folder (see `detect_input_board()`).

        Example: `"../predictions/board.jpg"`.

    :return: Length-64 list of paths to chess-piece images
    """
    head, tail = os.path.split(board_path)
    tmp_dir = os.path.join(head, "tmp/")
    pieces_dir = os.path.join(tmp_dir, "pieces/")
    os.mkdir(pieces_dir)
    split_board_image_trivial(os.path.join(tmp_dir, tail), "", pieces_dir)
    return sorted(glob.glob(pieces_dir + "/*.jpg"))


def time_predict_board(
    board_path,
    a1_pos,
    obtain_piece_probs_for_all_64_squares,
    previous_fen=None,
):
    """Time the FEN-prediction process.

    This function predicts the FEN string from a chessboard and prints
    out the elapsed times during the prediction.

    :param board_path: Path to the chessboard image of interest.

        The path must have rw permission.

        Example: `"../predictions/board.jpg"`.

    :param a1_pos: Position of the a1 square of the chessboard image.

        This is the position of the a1 square (`"BL"`, `"BR"`, `"TL"`,
        or `"TR"`) corresponding to the chessboard image.

    :param obtain_piece_probs_for_all_64_squares: Path-to-prob function.

        This function takes as input a length-64 list of paths to
        chess-piece images and returns a length-64 list of the
        corresponding piece probabilities (each element of the list is a
        length-13 sublist that contains 13 piece probabilities).

        This parameter allows us to deploy different inference engines
        (Keras, ONNX, or TensorRT).

    :param previous_fen: FEN string of the previous board position.

    :return: Predicted FEN string corresponding to the input chessboard
    image.
    """
    total_time = 0

    start = time.perf_counter()
    detect_input_board(board_path)
    elapsed_time = time.perf_counter() - start
    total_time += elapsed_time
    print(f"Elapsed time detecting the input board: {elapsed_time}")

    start = time.perf_counter()
    pieces = obtain_individual_pieces(board_path)
    elapsed_time = time.perf_counter() - start
    total_time += elapsed_time
    print(f"Elapsed time obtaining the individual pieces: {elapsed_time}")

    start = time.perf_counter()
    probs_with_no_indices = obtain_piece_probs_for_all_64_squares(pieces)
    elapsed_time = time.perf_counter() - start
    total_time += elapsed_time
    print(f"Elapsed time predicting probabilities: {elapsed_time}")

    start = time.perf_counter()
    predictions = infer_chess_pieces(
        probs_with_no_indices, a1_pos, previous_fen
    )
    elapsed_time = time.perf_counter() - start
    total_time += elapsed_time
    print(f"Elapsed time inferring chess pieces: {elapsed_time}")

    start = time.perf_counter()
    board = list_to_board(predictions)
    fen = board_to_fen(board)
    elapsed_time = time.perf_counter() - start
    total_time += elapsed_time
    print(f"Elapsed time converting to fen notation: {elapsed_time}")

    print(f"Elapsed total time: {total_time}")

    return fen


def print_fen_comparison(
    board_name: str, fen: str, correct_fen: str, used_previous_fen: bool
):
    """Compare predicted FEN with correct FEN and pretty-print result.

    :param board_name: Filename of the chessboard image.

        Example: `"test1.jpg"`.

    :param fen: Predicted FEN string.

    :param correct_fen: Correct FEN string.

    :param used_previous_fen: Whether the FEN string of the previous
    board position was used during the prediction.
    """
    n_dif = compare_fen(fen, correct_fen)
    used_previous_fen_str = (
        "_with_previous_fen" if used_previous_fen else "_without_previous_fen"
    )
    print(
        board_name[:-4]
        + used_previous_fen_str
        + " - Err:"
        + str(n_dif)
        + " Acc:{:.2f}% FEN:".format((1 - (n_dif / 64)) * 100)
        + fen
        + "\n"
    )


def read_correct_fen(
    fen_file: str,
) -> tuple[list[str], list[str], list[str | None]]:
    """Read the correct FENs.

    :param fen_file: Path to the correct-FEN file.

        This files contains the correct FENs, a1-square positions, and
        (optionally) correct previous FENs.

    :return: Length-3 tuple of the correct-FEN information.

        The first element of the tuple is a list of the correct FENs,
        the second is a list of the corresponding a1-square positions,
        and the third is a list of the corresponding correct previous
        FENs.

        Any `None` in the third list represents an unknown previous
        board position.
    """
    fens = []
    a1_squares = []
    previous_fens = []

    with open(fen_file, "r") as fen_fd:
        lines = fen_fd.read().splitlines()
        for line in lines:
            line = line.split()
            if not len(line) in [2, 3]:
                raise ValueError(
                    "All lines in fen file must have the format "
                    "'fen orientation [previous_fen]'"
                )
            fens.append(line[0])
            a1_squares.append(line[1])
            if len(line) == 2:
                previous_fens.append(None)
            else:
                previous_fens.append(line[2])
    return fens, a1_squares, previous_fens


def check_validity_of_fen(fen: str) -> bool:
    """Check validity of FEN assuming a standard physical chess set.

    This function checks the validity of a FEN string assuming a
    standard physical chess set.

    :param fen: FEN string whose validity is to be checked.

    :return: Whether the input FEN string is valid or not.
    """
    board = chess.Board(fen)
    if not board.is_valid():  # If it's white to move, the FEN is invalid
        board.turn = chess.BLACK
        if (
            not board.is_valid()
        ):  # If it's black to move, the FEN is also invalid
            return False

    num_of_P = fen.count("P")  # Number of white pawns
    num_of_Q = fen.count("Q")  # Number of white queens
    num_of_R = fen.count("R")  # Number of white rooks
    num_of_N = fen.count("N")  # Number of white knights
    num_of_p = fen.count("p")  # Number of black pawns
    num_of_q = fen.count("q")  # Number of black queens
    num_of_r = fen.count("r")  # Number of black rooks
    num_of_n = fen.count("n")  # Number of black knights
    fen_list = board_to_list(fen_to_board(fen))
    num_of_light_squared_B = sum(
        [
            is_light_square(square)
            for (square, piece_type) in enumerate(fen_list)
            if piece_type == "B"
        ]
    )  # Number of light-squared bishops for white
    num_of_dark_squared_B = (
        fen.count("B") - num_of_light_squared_B
    )  # Number of dark-squared bishops for white
    num_of_light_squared_b = sum(
        [
            is_light_square(square)
            for (square, piece_type) in enumerate(fen_list)
            if piece_type == "b"
        ]
    )  # Number of light-squared bishops for black
    num_of_dark_squared_b = (
        fen.count("b") - num_of_light_squared_b
    )  # Number of dark-squared bishops for black

    if (
        num_of_R > 2
        or num_of_r > 2
        or num_of_N > 2
        or num_of_n > 2
        or (num_of_light_squared_B + num_of_dark_squared_B) > 2
        or (num_of_light_squared_b + num_of_dark_squared_b) > 2
        or num_of_Q > 2
        or num_of_q > 2
    ):  # Number of any piece is too large for a standard physical chess set
        return False

    if (
        num_of_P == 7
        and num_of_Q == 2  # A white pawn has promoted into a queen
        and (
            num_of_light_squared_B == 2 or num_of_dark_squared_B == 2
        )  # A white pawn has promoted into a bishop
    ):
        return False

    if num_of_P == 8 and (
        num_of_Q == 2  # A white pawn has promoted into a queen
        or (num_of_light_squared_B == 2 or num_of_dark_squared_B == 2)
    ):  # A white pawn has promoted into a bishop
        return False

    if (
        num_of_p == 7
        and num_of_q == 2  # A black pawn has promoted into a queen
        and (
            num_of_light_squared_b == 2 or num_of_dark_squared_b == 2
        )  # A black pawn has promoted into a bishop
    ):
        return False

    if num_of_p == 8 and (
        num_of_q == 2  # A black pawn has promoted into a queen
        or (num_of_light_squared_b == 2 or num_of_dark_squared_b == 2)
    ):  # A black pawn has promoted into a bishop
        return False

    return True
