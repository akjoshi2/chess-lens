import os
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
import base64
import cv2
import numpy as np
import sys
sys.path.append("CV")
from lc2fen2 import getBoardFen
from lc2fen.detectboard import image_object
stockfish = Stockfish(path="stockfish.exe",depth=20, parameters={"Ponder": "false", "MultiPV": 3, "Hash": 256})
engine = chess.engine.SimpleEngine.popen_uci("stockfish.exe")
app = Flask(__name__)

@app.route("/getFen", methods=["POST"])
def getFen():
    res = {}
    img = request.form["image"]
    width = request.form["width"]
    height = request.form["height"]
    f= BytesIO(base64.b64decode(img))

    imagePath = yuv420_to_pillow(f, int(width), int(height))

    toPlay = request.form.get("toPlay", "w")

    res["uuid"] = request.form.get("uuid", uuid.uuid4())

    
    fen = getBoardFen(imagePath, None)

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

    
    
    # todo: need to change the fen to reflect whose move it is
    # first, we receive a uuid from the frontend, or nothing 

def getMoves(line, board):
    arr = []
    for move in line["pv"]:
        arr.append(board.san(move))
        board.push(move)
    for i in range(line["pv"]):
        board.pop()
    return arr

def getEval(fen):
    # Get the FEN parameter from the request
    # Check if the FEN parameter is missing
    if fen is None:
        return jsonify({"error": "Missing 'fen' parameter"}), 400

    board = chess.Board(fen)
    info = engine.analyse(board, chess.engine.Limit(time=2),multipv=3)
    
    lines = {}
    eval = ""
    for i in range(len(info)):
        arr = getMoves(info[i])
        lines[i+1] = {"evaluation": info[i]["score"].relative.score(mate_score=10000), "lines": " ".join(arr)}
        if i == 0:
            eval = info[i]["score"].relative.score(mate_score=10000)



    response = {"finalEval": lines[1]["evaluation"], "lines": lines}
    
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

def yuv420_to_pillow(f, width, height):
    # Read YUV420 image
        # Read Y, U and V color channels and reshape to height*1.5 x width numpy array
    yuv = np.frombuffer(f.read(width*height*3//2), dtype=np.uint8).reshape((height*3//2, width))

        # Convert YUV420 to BGR (for testing), applies BT.601 "Limited Range" conversion.
    bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2RGB_NV21)
    cv2.imwrite(os.path.join(".",'result.jpg'),bgr)
    return os.path.join(".",'result.jpg')
    

# f = urllib.parse.quote_plus("fen=rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 2")
# print(requests.get("http://localhost:5000/getEval", params={"fen": f}))