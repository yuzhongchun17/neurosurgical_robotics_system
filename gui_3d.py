import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from CAAR_Model import create_plot  # This needs to return x, y for 2D plotting
import matplotlib.pyplot as plt
import imageio.v2 as imageio
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import os

tip_positions = []

def rotate_data(x, y, angle):
    # Creating a 3D effect by rotating the 2D curve around the Z-axis
    rad = np.radians(angle)
    x_rot = x * np.cos(rad) - y * np.sin(rad)
    y_rot = x * np.sin(rad) + y * np.cos(rad)
    return x_rot, y_rot, y  # y is unchanged


def update_plot(ax, displacement, rotation_angle):
    global tip_positions

    fig = create_plot(displacement)  # Assuming this returns a Figure object

    # Extract x and y data from the first line in the first axes
    line = fig.axes[0].lines[0]
    x_data, y_data = line.get_xdata(), line.get_ydata()

    # Rotate data to create a 3D effect
    x_data, z_data, y_data = rotate_data(x_data, y_data, rotation_angle)

    ax.clear()

    # Set labels and limits
    ax.set_xlabel('X coordinate (mm)')
    ax.set_ylabel('Y coordinate (mm)')
    ax.set_zlabel('Z coordinate (mm)')
    ax.set_title("3D Visualization of 2D Curve")

    ax.set_xlim(-70, 70)
    ax.set_ylim(-70, 70)

    # Plot the curve
    ax.plot(x_data, y_data, z_data)

    # Save and plot the tip position
    if len(x_data) > 0 and len(y_data) > 0 and len(z_data) > 0:
        tip_positions.append((x_data[-1], y_data[-1], z_data[-1]))
        for tip_x, tip_y, tip_z in tip_positions:
            ax.scatter(tip_x, tip_y, tip_z, color='r')

def generate_plot(displacement, rotation, canvas, ax):
    update_plot(ax, displacement, rotation)
    canvas.draw()

def save_plot_frame(displacement, rotation, filename, ax):
    update_plot(ax, displacement, rotation)
    plt.savefig(filename)
    plt.close()

def create_gif(ax, rotation_scale):
    filenames = []
    # Create frames for the GIF
    for i in range(-25, 26):
        filename = f'frame_{i+25}.png'
        save_plot_frame(i, rotation_scale.get(), filename, ax)
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
    window.title("3D Curve Visualization")
    window.geometry("1000x800")

    fig = plt.figure(figsize=(10, 7), dpi=100)
    ax = fig.add_subplot(111, projection='3d')
    canvas = FigureCanvasTkAgg(fig, master=window)
    canvas.get_tk_widget().pack()

    # Base displacement slider
    displacement_label = tk.Label(window, text="Base Displacement, q (mm)", font=("Arial", 12))
    displacement_label.pack()

    displacement_scale = tk.Scale(window, from_=-20, to=20, orient='horizontal', font=("Arial", 10))
    displacement_scale.pack()

    # Rotation angle slider
    rotation_label = tk.Label(window, text="Rotation Angle (degrees)", font=("Arial", 12))
    rotation_label.pack()

    rotation_scale = tk.Scale(window, from_=0, to=360, orient='horizontal', font=("Arial", 10))
    rotation_scale.pack()

    # Update plot function
    def update():
        generate_plot(displacement_scale.get(), rotation_scale.get(), canvas, ax)

    displacement_scale.config(command=lambda value: update())
    rotation_scale.config(command=lambda value: update())

    update()

    # Create GIF button
    gif_button = tk.Button(window, text="Create GIF", command=lambda: create_gif(ax, rotation_scale))
    gif_button.pack()

    window.mainloop()

if __name__ == '__main__':
    main()
