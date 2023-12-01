import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from CAAR_Model import create_plot  # make sure this function returns a matplotlib Figure object
import matplotlib.pyplot as plt

def generate_plot(input_value, canvas, ax):
    # Clear the current Axes instance
    ax.clear()
    
    # Get the new figure using the input value
    fig = create_plot(int(input_value))
    
    
    ax.set_xlim(-100, 80)
    ax.set_ylim(0, 150)
    
    # Plot the data from the new figure onto the existing Axes
    ax.plot(fig.axes[0].lines[0].get_xdata(), fig.axes[0].lines[0].get_ydata())
    
    # Redraw the canvas with the new plot
    canvas.draw()

def on_button_click(entry, canvas, ax):
    input_value = entry.get()
    generate_plot(input_value, canvas, ax)

def main():
    # Set up the Tkinter window
    window = tk.Tk()
    window.title("Plot Generator")
    window.geometry("1000x800")

    # Create a Figure and a set of subplots
    #fig, ax = plt.subplots()
    fig, ax = plt.subplots(figsize=(10, 7), dpi=100)  # 100 dots per inch
    ax.set_xlim(-100, 80)
    ax.set_ylim(0, 150)
    
    # Create a Canvas to embed the plot in the Tkinter window
    canvas = FigureCanvasTkAgg(fig, master=window)
    canvas.get_tk_widget().pack()

    # Input field
    entry = tk.Entry(window)
    entry.pack()

    # Button to generate plot
    button = tk.Button(window, text="Generate Plot", command=lambda: on_button_click(entry, canvas, ax))
    button.pack()

    # Start the Tkinter event loop
    window.mainloop()

if __name__ == '__main__':
    main()
