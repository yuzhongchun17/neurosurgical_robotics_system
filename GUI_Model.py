import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from CAAR_Model import create_plot
import matplotlib.pyplot as plt
import imageio.v2 as imageio
import os

import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from CAAR_Model import create_plot  # This needs to return 3D data now
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import imageio.v2 as imageio
import numpy as np
import os


# # adding tranlational and rotational visualization code
# # add tip trace + potential workspace visualization also
# # putting two together
# # not simulation tho
tip_positions = []
def update_plot(ax, displacement, rotation_angle):
    global tip_positions

    ax.clear()
    fig = create_plot(displacement)  # Assuming this now returns 3D data

    # Extract x, y, z data
    x_data, y_data, z_data = fig.axes[0].get_xdata(), fig.axes[0].get_ydata(), fig.axes[0].get_zdata()

    # Rotate data
    x_data, y_data, z_data = rotate_data(x_data, y_data, z_data, rotation_angle)

    # Set labels and limits
    ax.set_xlabel('X coordinate (mm)')
    ax.set_ylabel('Y coordinate (mm)')
    ax.set_zlabel('Z coordinate (mm)')
    ax.set_title("3D Non-Constant Curvature: S-shape (2:1 ratio)")

    # Plot the curve
    ax.plot(x_data, y_data, z_data)

    # Save and plot the tip position
    if len(x_data) > 0 and len(y_data) > 0 and len(z_data) > 0:
        tip_positions.append((x_data[-1], y_data[-1], z_data[-1]))
        for tip_x, tip_y, tip_z in tip_positions:
            ax.scatter(tip_x, tip_y, tip_z, color='r') 

def rotate_data(x, y, z, angle):
    # Rotation around the z-axis
    rad = np.radians(angle)
    x_rot = x * np.cos(rad) - y * np.sin(rad)
    y_rot = x * np.sin(rad) + y * np.cos(rad)
    return x_rot, y_rot, z
# def update_plot(ax, value):
#     global tip_positions

#     ax.clear()
#     fig = create_plot(value)

#     # Extract x and y data
#     x_data = fig.axes[0].lines[0].get_xdata()
#     y_data = fig.axes[0].lines[0].get_ydata()

#     # Set labels and limits
#     ax.set_xlabel('x coordinate (mm)', fontsize=12)
#     ax.set_ylabel('z coordinate (mm)', fontsize=12)
#     ax.set_title("Non-Constant Curvature: S-shape (2:1 ratio)")
#     ax.set_xlim(-100, 80)
#     ax.set_ylim(0, 160)

#     # Plot the curve
#     ax.plot(x_data, y_data)

#     # Save and plot the tip position
#     if len(x_data) > 0 and len(y_data) > 0:
#         tip_positions.append((x_data[-1], y_data[-1]))
#         # Plot all tip positions to visualize the workspace area
#         for tip_x, tip_y in tip_positions:
#             ax.plot(tip_x, tip_y, 'ro')  # 'ro' stands for red color and circle marker



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

    # base displacement slider bar
    label = tk.Label(window, text="Base Displacement, q (mm)", font=("Arial", 12))
    label.pack()

    scale = tk.Scale(window, from_=-20, to=20, orient='horizontal', font=("Arial", 10))
    scale.pack()
    scale.config(command=lambda value: generate_plot(value, canvas, ax, scale))

    generate_plot(0, canvas, ax, scale)

    # create gif when click button
    gif_button = tk.Button(window, text="Create GIF", command=lambda: create_gif(ax))
    gif_button.pack()

    window.mainloop()

if __name__ == '__main__':
    main()
