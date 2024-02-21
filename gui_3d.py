import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from CAAR_Model import create_plot, calculation  # This needs to return x, y for 2D plotting
import matplotlib.pyplot as plt
import imageio.v2 as imageio
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import os

tip_positions = []
def rotate_data(x, y, z, angle):
    # Creating a 3D effect by rotating the 2D curve (in x-z plane) around the Z-axis
    rad = np.radians(angle)
    x_rot = x * np.cos(rad) - y * np.sin(rad)
    y_rot = x * np.sin(rad) + y * np.cos(rad)
    return x_rot, y_rot, z

def update_plot(ax, displacement, rotation_angle):
    global tip_positions

    x_data, z_data = calculation(displacement)
    # Initialize y_data as zeros since without rotation, the plot is in x-z plane at y=0
    y_data = np.zeros_like(x_data)

    # Rotate data to create a 3D effect if rotation_angle is not zero
    if rotation_angle != 0:
        x_data, y_data, z_data = rotate_data(x_data, y_data, z_data, rotation_angle)

    ax.clear()

    ax.set_xlabel('X coordinate (mm)')
    ax.set_ylabel('Y coordinate (mm)')
    ax.set_zlabel('Z coordinate (mm)')
    ax.set_title("3D Curve Visualization of the Non-Constant Curvature: S-shape (2:1 ratio)")

     # Plot the curve with a label for the displacement and rotation angle
    label = f"Displacement: {displacement} mm, Rotation: {rotation_angle}°"
    ax.plot(x_data, y_data, z_data, 'b-', label=label)  # Plot as a blue line with a label
    ax.legend()

    ax.set_xlim(-70, 70)
    ax.set_ylim(-70, 70)
    ax.set_zlim(0, 150)  

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

    
def create_gif(ax, canvas, output_filename='plot_animation.gif', duration=0.1):
    displacement_range = np.linspace(0, 20, 10, dtype=int)  # 20 points from -20 to 20 inclusive for displacement
    rotation_range = np.linspace(0, 359, 15, dtype=int)  # 30 steps for full rotation

    filenames = []
    for displacement in displacement_range:
        for rotation_angle in rotation_range:
            # Update the plot for the current displacement and rotation
            update_plot(ax, displacement, rotation_angle)
            canvas.draw()

            # Save the current frame
            filename = f'frame_{displacement}_{rotation_angle}.png'
            plt.savefig(filename)
            filenames.append(filename)

    # Create the GIF
    with imageio.get_writer(f'{output_filename}', mode='I', duration=duration) as writer:
        for filename in filenames:
            image = imageio.imread(filename)
            writer.append_data(image)
            # os.remove(filename)  # Remove files immediately after adding to GIF to save space

    print("GIF created successfully!")


def main():
    window = tk.Tk()
    window.title("3D Curve Visualization of the Non-Constant Curvature: S-shape (2:1 ratio)")
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

    # Create GIF button - modified to pass the ranges for displacement and rotation
    gif_button = tk.Button(window, text="Create GIF", command=lambda: create_gif(ax, canvas))
    gif_button.pack()

    window.mainloop()

if __name__ == '__main__':
    main()
