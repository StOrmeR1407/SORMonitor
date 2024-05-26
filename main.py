from typing import Union
from fastapi import FastAPI
from datetime import datetime
import datetime
import psutil
import win32gui
import win32process

app = FastAPI()

@app.get("/")
def read_root():
    return {"name": "Học", "age":"23"}

@app.get("/getinfo")
def getstatus():
    data = {}
    try:
        hwnd = win32gui.GetForegroundWindow()

        # Lấy PID của tiến trình từ handle của cửa sổ
        _, pid = win32process.GetWindowThreadProcessId(hwnd)

        # Lấy tên chương trình từ PID
        process = psutil.Process(pid)
        executable_name = process.name()

        # Lấy tiêu đề của cửa sổ
        window_title = win32gui.GetWindowText(hwnd)
        if(executable_name.find('chrome') == 0 or executable_name.find('browser') == 0):
            suffixes = [" - Google Chrome"," - Cốc Cốc"]
            for suffix in suffixes:    
                if(window_title.endswith(suffix)):
                    window_title = window_title[:-len(suffix)]
                    break
            data["name"] = window_title
        else:
            data["name"] = executable_name
        data["time"] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    except Exception as ex:
        data["name"] = False
        data["time"] = False
    return data

