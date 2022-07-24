import tkinter as tk
from tkinter import ttk

root = tk.Tk()

# style = ttk.Style(root)
style = ttk.Style(root)
style = ttk.Style()
style.theme_settings("default", {"TNotebook.Tab": {"configure": {"padding": [40, 40]}}})

style.configure('lefttab.TNotebook', tabposition='wn')

notebook = ttk.Notebook(root, style='lefttab.TNotebook')

f1 = tk.Frame(notebook, bg='red', width=200, height=200)
f2 = tk.Frame(notebook, bg='blue', width=200, height=200)

notebook.add(f1, text='CPU')
notebook.add(f2, text='RAM')

notebook.grid(row=0, column=0, sticky="nw")

root.mainloop()