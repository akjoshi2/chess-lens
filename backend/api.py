import requests
from flask import Flask, request, jsonify
from stockfish import Stockfish

stockfish = Stockfish(depth=20, parameters={"Ponder": "false", "MultiPV": 3})

app = Flask(__name__)

@app.route("/getFen", methods=["GET"])
def getFen():
    params = {}
    params["image"] = request.args["image"]
    params["toPlay"] = request.args["toPlay"]
    return ""

@app.route("/getEval", methods=["GET"])
def getEval():
    # Get the FEN parameter from the request

    fen = request.args.get("fen")
    
    # Check if the FEN parameter is missing
    if fen is None:
        return jsonify({"error": "Missing 'fen' parameter"}), 400

    # Set up Stockfish analysis
    stockfish.set_fen_position(fen)
    
    # Create a dictionary to store lines
    pv_lines = stockfish.get_top_moves(5)
    lines = {}
    for i, line in enumerate(pv_lines, start=1):
        lines[i] = line

    # Create the response JSON
    response = {"evaluation": stockfish.get_evaluation(), "lines": lines}
    
    # Return the response as JSON
    return jsonify(response)

# import urllib
# f = urllib.parse.quote_plus("fen=rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 2")
# print(requests.get("http://localhost:5000/getEval", params={"fen": f}))