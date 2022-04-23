import os
import sys
import time
import pathlib
import socket
import shutil
import datetime
os.system('cls' if os.name == 'nt' else 'clear')

while True:
    TCP_IP = "streaming1.naad-adna.pelmorex.com"
    TCP_PORT = 8080
    BUFFER_SIZE = 100000
    NAAD1 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    NAAD1.connect((TCP_IP, TCP_PORT))
    print("WE ARE CONNECTED TO PELMOREX NAAD 1")
    print(NAAD1)
    NAAD1.settimeout(90)
    
    try:
        data = str(NAAD1.recv(BUFFER_SIZE),encoding='utf-8', errors='ignore')
    except socket.timeout:
        os.system('cls' if os.name == 'nt' else 'clear')
        print("ERROR - Timed out, trying again. Maybe check your network connection?")
        time.sleep(10)
    else:   
        while 'NAADS-Heartbeat' in data:
            os.system('cls' if os.name == 'nt' else 'clear')
            print(time.strftime("Heartbeat recived at %H:%M:%S on %d/%m/%Y"))
            print(str(data))
            try:
                data = str(NAAD1.recv(BUFFER_SIZE),encoding='utf-8', errors='ignore')
            except socket.timeout:
                os.system('cls' if os.name == 'nt' else 'clear')
                print("ERROR - Timed out, trying again. Maybe check your network connection?")
                NAAD1.close()
                time.sleep(10)
                NAAD1 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                NAAD1.connect((TCP_IP, TCP_PORT))
            else:
                print(time.strftime("Heartbeat recived at %H:%M:%S on %d/%m/%Y"))
                print(str(data))
                
        os.system('cls' if os.name == 'nt' else 'clear')
        print(str(data))
        
        TIM = datetime.datetime.now()
        timeQ = TIM.strftime("quene/alert%d%m%YT%H%M%S%f.xml")
        timeX = TIM.strftime("xmls/alert%d%m%YT%H%M%S%f.xml")
        alert = open(timeQ, 'a')
        alert.write(str(data))
        
        while '</alert>' not in data:
            data = str(NAAD1.recv(BUFFER_SIZE),encoding='utf-8', errors='ignore')
            print(str(data))
            alert.write(str(data))
                
        alert.close()
        shutil.move(timeQ, timeX)
        print(time.strftime("Transmission recived at %H:%M:%S on %d/%m/%Y"))
    NAAD1.close()

#867-5309
