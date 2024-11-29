import tkinter as tk
from tkinter import messagebox, ttk
import sqlite3

# Fungsi untuk menghubungkan ke database SQLite
def connect_db():
    return sqlite3.connect("users.db")

# Fungsi untuk membuat tabel jika belum ada
def create_table():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            email TEXT,
            password TEXT
        )
    ''')
    conn.commit()
    conn.close()

# Fungsi untuk menambah data pengguna
def add_data():
    nama = entry_nama.get()
    email = entry_email.get()
    password = entry_password.get()
    if not email.endswith('@gmail.com'):
        messagebox.showwarning("Error Email", "Email harus berakhiran @gmail.com!")
        return
    if nama and email and password:
        conn = connect_db()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO users (nama, email, password) VALUES (?, ?, ?)", (nama, email, password))
        conn.commit()
        conn.close()
        treeview.insert('', '0', values=(nama, email, password))
        entry_nama.delete(0, tk.END)
        entry_email.delete(0, tk.END)
        entry_password.delete(0, tk.END)
        messagebox.showinfo("Sukses", "Data berhasil ditambahkan!")
    else:
        messagebox.showwarning("Error Input", "Semua field harus diisi!")

# Fungsi untuk mengupdate data pengguna
def update_data():
    selected_item = treeview.selection()
    if not selected_item:
        messagebox.showwarning("Error Pilihan", "Pilih data yang ingin diubah.")
        return
    selected_item = selected_item[0]
    new_nama = entry_nama.get()
    new_email = entry_email.get()
    new_password = entry_password.get()
    if not new_email.endswith('@gmail.com'):
        messagebox.showwarning("Error Email", "Email harus berakhiran @gmail.com!")
        return
    if new_nama and new_email and new_password:
        conn = connect_db()
        cursor = conn.cursor()
        cursor.execute("UPDATE users SET nama = ?, email = ?, password = ? WHERE nama = ? AND email = ? AND password = ?",
                       (new_nama, new_email, new_password, 
                        treeview.item(selected_item, 'values')[0], 
                        treeview.item(selected_item, 'values')[1], 
                        treeview.item(selected_item, 'values')[2]))
        conn.commit()
        conn.close()
        messagebox.showinfo("Sukses", "Data berhasil diubah!")
        load_data()
        entry_nama.delete(0, tk.END)
        entry_email.delete(0, tk.END)
        entry_password.delete(0, tk.END)
        btn_add.config(state=tk.NORMAL)
        btn_update.config(state=tk.DISABLED)
        btn_delete.config(state=tk.DISABLED)

# Fungsi untuk menghapus data pengguna
def delete_data():
    selected_item = treeview.selection()
    if not selected_item:
        messagebox.showwarning("Error Pilihan", "Pilih data yang ingin dihapus.")
        return
    selected_item = selected_item[0]
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM users WHERE nama = ? AND email = ? AND password = ?",
                   (treeview.item(selected_item, 'values')[0], 
                    treeview.item(selected_item, 'values')[1], 
                    treeview.item(selected_item, 'values')[2]))
    conn.commit()
    conn.close()
    messagebox.showinfo("Sukses", "Data berhasil dihapus!")
    load_data()
    entry_nama.delete(0, tk.END)
    entry_email.delete(0, tk.END)
    entry_password.delete(0, tk.END)
    btn_add.config(state=tk.NORMAL)
    btn_update.config(state=tk.DISABLED)
    btn_delete.config(state=tk.DISABLED)

# Fungsi untuk mencari data pengguna berdasarkan nama
def search_data():
    query = entry_search.get()
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE nama LIKE ?", ('%' + query + '%',))
    rows = cursor.fetchall()
    conn.close()
    for row in treeview.get_children():
        treeview.delete(row)
    for row in rows:
        treeview.insert('', 'end', values=(row[1], row[2], row[3]))

# Fungsi untuk memuat dan menampilkan semua data pengguna
def load_data():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users")
    rows = cursor.fetchall()
    conn.close()
    for row in treeview.get_children():
        treeview.delete(row)
    for row in rows:
        treeview.insert('', 'end', values=(row[1], row[2], row[3]))

# Fungsi untuk menangani pemilihan item di Treeview
def on_select(event):
    selected_item = treeview.selection()
    if selected_item:
        selected_data = treeview.item(selected_item[0])['values']
        entry_nama.delete(0, tk.END)
        entry_nama.insert(0, selected_data[0])
        entry_email.delete(0, tk.END)
        entry_email.insert(0, selected_data[1])
        entry_password.delete(0, tk.END)
        entry_password.insert(0, selected_data[2])
        btn_add.config(state=tk.DISABLED)
        btn_update.config(state=tk.NORMAL)
        btn_delete.config(state=tk.NORMAL)
    else:
        btn_add.config(state=tk.NORMAL)
        btn_update.config(state=tk.DISABLED)
        btn_delete.config(state=tk.DISABLED)

# Fungsi untuk login yang menggunakan email dan password yang sudah ditentukan
def login():
    # Email dan password yang sudah ditentukan
    valid_email = "vannmc959@gmail.com"
    valid_password = "Evancute22"

    # Mengambil input dari form login
    email = entry_email_login.get()
    password = entry_password_login.get()

    if email == valid_email and password == valid_password:
        messagebox.showinfo("Login Sukses", "Berhasil login!")
        login_window.withdraw()  # Sembunyikan jendela login
        main_window.deiconify()   # Tampilkan jendela utama
    else:
        messagebox.showerror("Login Gagal", "Email atau password salah!")

# Fungsi untuk logout
def logout():
    main_window.withdraw()  # Sembunyikan jendela utama
    login_window.deiconify()  # Tampilkan jendela login

# Jendela Login
login_window = tk.Tk()
login_window.title("Login")
login_window.geometry("400x300")
login_window.configure(bg='#e0f7fa')

label_email_login = tk.Label(login_window, text="Email", font=("Arial", 12), bg='#e0f7fa')
label_email_login.pack(pady=10)
entry_email_login = tk.Entry(login_window, font=("Arial", 14), width=30)
entry_email_login.pack(pady=10)

label_password_login = tk.Label(login_window, text="Password", font=("Arial", 12), bg='#e0f7fa')
label_password_login.pack(pady=10)
entry_password_login = tk.Entry(login_window, font=("Arial", 14), show="*", width=30)
entry_password_login.pack(pady=10)

btn_login = tk.Button(login_window, text="Login", command=login, font=("Arial", 14), bg='#4CAF50', fg='white')
btn_login.pack(pady=20)

# Jendela Utama
main_window = tk.Tk()
main_window.title("Pengelolaan Data Pengguna")
main_window.geometry("600x500")
main_window.configure(bg='#e0f7fa')
main_window.withdraw()  # Sembunyikan jendela utama pada awalnya

input_frame = tk.Frame(main_window, bg='#e0f7fa')
input_frame.pack(pady=20)

# Komponen input untuk Nama, Email, dan Password
label_nama = tk.Label(input_frame, text="Nama", font=("Arial", 12), bg='#e0f7fa')
label_nama.grid(row=0, column=0, padx=10, pady=10, sticky="w")
entry_nama = tk.Entry(input_frame, font=("Arial", 14), width=30)
entry_nama.grid(row=0, column=1, padx=10, pady=10)

label_email = tk.Label(input_frame, text="Email", font=("Arial", 12), bg='#e0f7fa')
label_email.grid(row=1, column=0, padx=10, pady=10, sticky="w")
entry_email = tk.Entry(input_frame, font=("Arial", 14), width=30)
entry_email.grid(row=1, column=1, padx=10, pady=10)

label_password = tk.Label(input_frame, text="Password", font=("Arial", 12), bg='#e0f7fa')
label_password.grid(row=2, column=0, padx=10, pady=10, sticky="w")
entry_password = tk.Entry(input_frame, font=("Arial", 14), show="*", width=30)
entry_password.grid(row=2, column=1, padx=10, pady=10)

button_frame = tk.Frame(main_window, bg='#e0f7fa')
button_frame.pack(pady=10)

btn_add = tk.Button(button_frame, text="Tambah Data", command=add_data, font=("Arial", 14), width=15, bg='#4CAF50', fg='white')
btn_add.pack(side=tk.LEFT, padx=5)

btn_update = tk.Button(button_frame, text="Ubah Data", command=update_data, font=("Arial", 14), width=15, bg='#2196F3', fg='white', state=tk.DISABLED)
btn_update.pack(side=tk.LEFT, padx=5)

btn_delete = tk.Button(button_frame, text="Hapus Data", command=delete_data, font=("Arial", 14), width=15, bg='#F44336', fg='white', state=tk.DISABLED)
btn_delete.pack(side=tk.LEFT, padx=5)

# Frame untuk pencarian
search_frame = tk.Frame(main_window, bg='#e0f7fa')
search_frame.pack(pady=10)

label_search = tk.Label(search_frame, text="Cari Nama", font=("Arial", 12), bg='#e0f7fa')
label_search.grid(row=0, column=0, padx=10, pady=10, sticky="w")
entry_search = tk.Entry(search_frame, font=("Arial", 14), width=20)
entry_search.grid(row=0, column=1, padx=10, pady=10)

btn_search = tk.Button(search_frame, text="Cari", command=search_data, font=("Arial", 14), width=10, bg='#FFC107', fg='black')
btn_search.grid(row=0, column=2, padx=10, pady=10)

# Treeview untuk menampilkan data pengguna
columns = ('Nama', 'Email', 'Password')
treeview = ttk.Treeview(main_window, columns=columns, show='headings', height=10)
treeview.pack(pady=20)

for col in columns:
    treeview.heading(col, text=col)

treeview.bind("<<TreeviewSelect>>", on_select)

# Tombol Logout
btn_logout = tk.Button(main_window, text="Logout", command=logout, font=("Arial", 14), width=15, bg='#FF5722', fg='white')
btn_logout.pack(pady=20)

# Membuat tabel pengguna jika belum ada
create_table()

# Menjalankan aplikasi login terlebih dahulu
login_window.mainloop()