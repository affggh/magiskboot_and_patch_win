# 脚本 by affggh
import os
import sys
import subprocess
import tkinter as tk 
from tkinter.filedialog import *
from tkinter import ttk
from tkinter import *

import base64
root = tk.Tk()

root.resizable(0,0) # 设置最大化窗口不可用

def logo():
    os.chdir(os.path.abspath(os.path.dirname(sys.argv[0])))
    root.iconbitmap('bin\\logo.ico')

logo()

filename = tk.StringVar()
is64bit = tk.StringVar()
keepverity = tk.StringVar()
keepforceencrypt = tk.StringVar()
mutiseletion = tk.StringVar()

text = Text(root,width=50,height=15)

def showinfo(textmsg):
    textstr = textmsg
    text.insert(END, textstr + "\n")

def select(*args):
    #showinfo("Selected Magisk Version is : %s" %(comboxlist.get()))
    showinfo("你已绑定Magisk版本为 : [%s]" %(mutiseletion.get()))

def selectFile():
	filepath = askopenfilename()  # 选择打开什么文件，返回文件名
	filename.set(filepath)      # 设置变量filename的值

def PatchBoot():
    # cmd = 'cmd.exe d:/start.bat'
    os.chdir(os.path.abspath(os.path.dirname(sys.argv[0])))
    p = os.system("cmd.exe /c" + "boot_patch.bat " + "%s " %(filename.get()) + "%s " %(is64bit.get()) + "%s " %(keepverity.get()) + "%s " %(keepforceencrypt.get()) + "%s" %(mutiseletion.get()))
    #p = subprocess.check_output(['boot_patch.bat',"%s" %(filename.get()),"%s" %(is64bit.get()),"%s" %(keepverity.get()),"%s" %(keepforceencrypt.get())],stderr=subprocess.STDOUT)
    showinfo(str(p))

def cmd_test():
    # cmd = 'cmd.exe d:/start.bat'
    os.chdir(os.path.abspath(os.path.dirname(sys.argv[0])))
    p = subprocess.Popen("cmd.exe /c" + "logo_dumper.bat " + "%s " %(filename.get()) + "extract", stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    curline = p.stdout.readline()
    while (curline != b''):
        print(curline)
        curline = p.stdout.readline()
    p.wait()
    print(p.returncode)

root.title("Magisk Patcher by 酷安 affggh")

# 构建“选择文件”这一行的标签、输入框以及启动按钮，同时我们希望当用户选择图片之后能够显示原图的基本信息
tk.Label(root, text='选择文件').grid(row=1, column=0, padx=5, pady=5)
tk.Entry(root, width=50,textvariable=filename).grid(row=1, column=1, padx=5, pady=5)
tk.Button(root, text='选择文件', command=selectFile).grid(row=1, column=2, padx=5, pady=5)

tk.Label(root, text='64位镜像').grid(row=2, column=0, padx=5, pady=5)
is64bit.set("true")
tk.Radiobutton(root, text='是',variable=is64bit, value='true').grid(row=2, column=1, padx=5, pady=5)
tk.Radiobutton(root, text='否',variable=is64bit, value='false').grid(row=2, column=2, padx=5, pady=5)

tk.Label(root, text='保持验证').grid(row=3, column=0, padx=5, pady=5)
keepverity.set("false")
tk.Radiobutton(root, text='是',variable=keepverity, value='true').grid(row=3, column=1, padx=5, pady=5)
tk.Radiobutton(root, text='否',variable=keepverity, value='false').grid(row=3, column=2, padx=5, pady=5)

tk.Label(root, text='保持强制加密').grid(row=4, column=0, padx=5, pady=5)
keepforceencrypt.set("false")
tk.Radiobutton(root, text='是',variable=keepforceencrypt, value='true').grid(row=4, column=1, padx=5, pady=5)
tk.Radiobutton(root, text='否',variable=keepforceencrypt, value='false').grid(row=4, column=2, padx=5, pady=5)
#  
tk.Label(root, text='选择Magisk版本').grid(row=5, column=0, padx=5, pady=5)
comboxlist = ttk.Combobox(root, textvariable=mutiseletion)
comboxlist["values"]=("Magisk-23.0","Magisk-22.1","Magisk-21.4","Magisk-20.4","custom") 
comboxlist.current(0) # 选择第一个
comboxlist.bind("<<ComboboxSelected>>",select)
comboxlist.grid(row=5, column=1, padx=5, pady=5)

tk.Button(root, text='修补boot镜像', width=12, height=2, command=PatchBoot).grid(row=5, column=2, padx=5, pady=5)

text.grid(row=6, column=1, padx=5, pady=5)
showinfo("请选择一个文件进行修补\n自定义版本需要将文件放进custom文件夹\n自定义版本不支持magisk22.1以下的版本...\n    本脚本编写by affggh\n    请自行根据控制台返回值0/1来判断修补是否成功\n    0 = 成功\n    1 = 失败")
root.mainloop()