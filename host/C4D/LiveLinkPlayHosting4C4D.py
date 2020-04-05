import c4d
import socket

def main():
    #fps = doc.GetFps()
    bTime = doc.GetTime()
    #f = bTime.GetFrame(fps)
    #print(fps, f)

    client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client.sendto(str(bTime.Get()) , ('127.0.0.1', 50000))
    client.close()