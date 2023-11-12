"""This script executes the detection of chessboards."""


from lc2fen.board2data import regenerate_data_folder, process_input_boards, split_detected_square_boards
from cpmodels.dataset import randomize_dataset, split_dataset

def main():
    """Detect all the chessboards in the "data" folder."""
    regenerate_data_folder("data")
    process_input_boards("data")
    split_detected_square_boards("data")
    split_dataset("data/pieces","data/train","data/validation")


if __name__ == "__main__":
    main()
