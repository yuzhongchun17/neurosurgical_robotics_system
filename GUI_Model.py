import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from CAAR_Model import create_plot
import matplotlib.pyplot as plt
import imageio.v2 as imageio
import os

def update_plot(ax, value):
    ax.clear()
    fig = create_plot(value)
    ax.set_xlabel('x coordinate (mm)', fontsize=12)
    ax.set_ylabel('z coordinate (mm)', fontsize=12)
    ax.set_title("Non-Constant Curvature: S-shape (2:1 ratio)")
    ax.set_xlim(-100, 80)
    ax.set_ylim(0, 160)
    ax.plot(fig.axes[0].lines[0].get_xdata(), fig.axes[0].lines[0].get_ydata())

def generate_plot(value, canvas, ax, scale):
    input_value = scale.get()
    update_plot(ax, input_value)
    canvas.draw()

def save_plot_frame(value, filename, ax):
    update_plot(ax, value)
    plt.savefig(filename)
    plt.close()

def create_gif(ax):
    filenames = []
    # Forward sequence
    for i in range(-25, 26):
        filename = f'frame_forward_{i+25}.png'  # Unique filename for forward frames
        save_plot_frame(i, filename, ax)
        filenames.append(filename)

    # Reverse sequence
    for i in range(24, -26, -1):
        filename = f'frame_reverse_{i+25}.png'  # Unique filename for reverse frames
        save_plot_frame(i, filename, ax)
        filenames.append(filename)


    with imageio.get_writer('plot_animation.gif', mode='I') as writer:
        for filename in filenames:
            image = imageio.imread(filename)
            writer.append_data(image)

    for filename in filenames:
        os.remove(filename)

    print("GIF created successfully!")

def main():
    window = tk.Tk()
    window.title("Plot Generator")
    window.geometry("1000x800")

    fig, ax = plt.subplots(figsize=(10, 7), dpi=100)
    canvas = FigureCanvasTkAgg(fig, master=window)
    canvas.get_tk_widget().pack()

    label = tk.Label(window, text="Base Displacement, q (mm)", font=("Arial", 12))
    label.pack()

    scale = tk.Scale(window, from_=-25, to=25, orient='horizontal', font=("Arial", 10))
    scale.pack()
    scale.config(command=lambda value: generate_plot(value, canvas, ax, scale))

    generate_plot(0, canvas, ax, scale)

    gif_button = tk.Button(window, text="Create GIF", command=lambda: create_gif(ax))
    gif_button.pack()

    window.mainloop()

if __name__ == '__main__':
    main()
