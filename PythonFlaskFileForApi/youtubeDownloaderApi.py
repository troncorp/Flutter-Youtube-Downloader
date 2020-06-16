from flask import Flask,request,jsonify
import os

app = Flask(__name__)

@app.route('/api',methods=['GET'])
def hello_world():
    d = dict()
    l = str(request.args['link'])
    os.system(f"youtube-dl -s -e -g {l}>vedioAudiolink.txt")
    fp = open('vedioAudiolink.txt')
    c = 0 
    for valink in fp:
        if c==0:
            d['title'] = valink
        elif c==1:
            d['videolink'] = valink
        else:
            d['audiolink'] = valink
        c+=1
    print(d)
    fp.close()
    os.system("rm vedioAudiolink.txt")
    return jsonify(d)


if __name__ == "__main__":
    app.run()