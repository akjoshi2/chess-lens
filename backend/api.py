import requests
from flask import Flask, request, jsonify
from stockfish import Stockfish
import base64
from PIL import Image
from io import BytesIO
import uuid
import db
import chess
import chess.engine
import imageio
import sys
sys.path.append("/CV")
from lc2fen import getBoardFen


stockfish = Stockfish(depth=20, parameters={"Ponder": "false", "MultiPV": 3, "Hash": 256})

app = Flask(__name__)

@app.route("/getFen", methods=["GET"])
def getFen():
    res = {}
    img = request.args["image"]
    width = request.args["width"]
    height = request.args["height"]
    
    checkImg = yuv420_to_pillow(img, width, height)

    toPlay = request.args.get("toPlay")

    res["uuid"] = request.args.get("uuid", uuid.uuid4())

    try:
        fen = getBoardFen(checkImg)

        newFen = fen
        if(not toPlay):
            # this occurs on non-first render, we need to fetch from the db what the last move was, then change newFen, 
            checkToMove = db.get_entry("uuid").split(" ")[-5]
            if(checkToMove):
                if checkToMove == "w":
                    newFen += " b"
                else:
                    newFen += " w"
        else: 
            # this occurs when toPlay is specified, aka on first render. We need to insert db the new uuid, along with the updated fen
            newFen += " " + toPlay
        
        
        move, check = is_one_move_away(fen, newFen)
        if not check:
            newFen = fen

        newFen = apply_uci_move_to_fen(newFen, move)
        db.insert_db(newFen, res["uuid"])
        
        res.update(getEval(newFen))
        alg_move = uci_to_algebraic(newFen, move)
        res.update({"move": alg_move})
        return res
    
    except ValueError:
        return {}

    
    
    # todo: need to change the fen to reflect whose move it is
    # first, we receive a uuid from the frontend, or nothing 

def getEval(fen):
    # Get the FEN parameter from the request
    # Check if the FEN parameter is missing
    if fen is None:
        return jsonify({"error": "Missing 'fen' parameter"}), 400

    # Set up Stockfish analysis
    stockfish.set_fen_position(fen)
    # Create a dictionary to store lines
    pv_lines = stockfish.get_top_moves(5)
    if not pv_lines:
        return {"evaluation": "finished", "lines": "none"}
    lines = {}
    for i, line in enumerate(pv_lines, start=1):
        lines[i] = line
        lines[i]["Move"] = uci_to_algebraic(fen, lines[i]["Move"])

    adjustedEval = lines[1]["Centipawn"]
    if(lines[1]["Mate"]):
        adjustedEval = str(lines[1]["Mate"]) + "M"

    response = {"evaluation": adjustedEval, "lines": lines}
    
    # Return the response as JSON
    return jsonify(response)


def is_one_move_away(fen1, fen2):
    board1 = chess.Board(fen1)
    board2 = chess.Board(fen2)

    # Generate legal moves for the first position
    legal_moves = list(board1.legal_moves)

    # Check if the second position is reachable by making exactly one legal move
    for move in legal_moves:
        # Make the move on a copy of the board
        temp_board = board1.copy()
        temp_board.push(move)

        # Check if the resulting position matches the second FEN
        if temp_board.fen() == fen2:
            return move, True

    return False

def uci_to_algebraic(fen, uci_move):
    board = chess.Board(fen)

    # Convert UCI move to chess.Move object
    move = chess.Move.from_uci(uci_move)

    # Apply the move to the board

    # Convert the move to algebraic notation
    print(uci_move)
    algebraic_move = board.san(move)

    return algebraic_move

# @app.route("/gettestres", methods=["GET"])
# def gettestres():
#     fen1 = request.args["fen1"]
#     uci = request.args["uci"]
#     return {"Answer": apply_uci_move_to_fen(fen1, uci)}

def apply_uci_move_to_fen(fen, uci_move):
    # Create a chess.Board object from the FEN
    board = chess.Board(fen)

    # Convert UCI move to chess.Move object
    move = chess.Move.from_uci(uci_move)

    # Apply the move to the board
    board.push(move)

    # Get the updated FEN after the move
    updated_fen = board.fen()

    return updated_fen

def yuv420_to_pillow(yuv_file, width, height):
    # Read YUV420 image
    yuv_image = imageio.imread(yuv_file)

    # Convert YUV420 to RGB
    rgb_image = imageio.core.util.yuv420p_to_rgb(yuv_image, width, height)

    # Create Pillow Image object from RGB array
    pillow_image = Image.fromarray(rgb_image)

    return pillow_image

# import urllib
# f = urllib.parse.quote_plus("fen=rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 2")
# print(requests.get("http://localhost:5000/getEval", params={"fen": f}))