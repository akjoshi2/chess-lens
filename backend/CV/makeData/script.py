import os
import shutil

def rename_and_create_fen(directory_path, output_directory):
    map = {"DefaultPos":"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR BL", 
           "MovedPos": "8/8/rnbqkbnr/pppppppp/PPPPPPPP/RNBQKBNR/8/8 BL",
           "IntricatePos":"2rq1rk1/pp2ppbp/2np1np1/8/2B1PPbP/2N1BN2/PP4P1/R2Q1RK1 BL",
           "PosTL":"2rq1rk1/pp2ppbp/2np1np1/8/2B1PPbP/2N1BN2/PP4P1/R2Q1RK1 TL"}
    # Create the output directory if it doesn't exist
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    # Initialize a counter for renaming files
    counter = 1

    # Create or open the fen.txt file for writing
    with open(os.path.join(output_directory, 'boards.fen'), 'w') as fen_file:
        # Iterate through Data1 and Data2 directories
        for data_directory in ['DefaultPos', 'MovedPos', 'IntricatePos', 'PosTL']:
            current_directory = os.path.join(directory_path, 'ChessData', data_directory)

            # Iterate through files in the current directory
            for filename in os.listdir(current_directory):
                # Get the file extension
                _, file_extension = os.path.splitext(filename)

                # Create the new filename (photo1.jpg, photo2.jpg, etc.)
                new_filename = f'photo{counter}{file_extension}'

                # Update the fen.txt file with the corresponding directory
                fen_file.write(f'{map[data_directory]}\n')

                # Copy and rename the file to the output directory
                shutil.copy2(os.path.join(current_directory, filename), os.path.join(output_directory, new_filename))

                # Increment the counter
                counter += 1

if __name__ == "__main__":
    # Set the input directory path and output directory path
    input_directory = '.'  # Change this to the actual path where ChessData is located
    output_directory = 'input'

    # Call the function to rename files and create fen.txt
    rename_and_create_fen(input_directory, output_directory)
