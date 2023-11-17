# Importing required libraries
import numpy as np
from numpy import pi,sin,cos,arccos
import matplotlib.pyplot as plt
from scipy.integrate import cumtrapz
from scipy.optimize import fsolve

# Given design specifications

OD_o = 8.5  # Outer tube #mm
ID_o = 7.0 
OR_o = OD_o/2 # outer radius for outer tube
IR_o = ID_o/2

OD_i = 5.5   # Inner tube, outer diameter
ID_i = 4 
OR_i = OD_i/2 # outer radius for inner tube
IR_i = ID_i/2
# print(OR_i,OR_o)

n = 15  # Number of notches


c = 5 #mm (outer) (for both inner and outer tube)
h = 5 # mm
g_o = 7.5
g_i = 4.5

L_curve = (c+h)*n # Length of curve in mm

phi_o = [pi if i < 5 else 0 for i in range(n)]
phi_i = [0 if i < 5 else pi for i in range(n)]

# Given: depth g, inner radius r_i, outer radius r_o
# Find: neutral bending plane, y
def calculate_ybar(g, r_i, r_o):
    from math import sin, acos, pi

    # Ensure the arguments for acos are within the valid range [-1, 1]
    arg_o = (g - r_o) / r_o
    arg_i = (g - r_o) / r_i
    # print("Arg_i:",arg_i, "Arg_o:",arg_o)
    if not (-1 <= arg_o <= 1 and -1 <= arg_i <= 1):
        return "Error: Input results out of domain for acos function."
    

    # Calculate phi_o and phi_i (phi here refering to CPPR paper 1)
    phi_o = 2 * arccos(arg_o)
    phi_i = 2 * arccos(arg_i)
    # print(phi_i, phi_o)

    # Calculate areas A_o and A_i
    A_o = (r_o**2 * (phi_o - sin(phi_o))) / 2
    A_i = (r_i**2 * (phi_i - sin(phi_i))) / 2
    # print(A_i, A_o)

    # Calculate centroids y_o and y_i
    y_o = (4 * r_o * sin(0.5 * phi_o)**3) / (3 * (phi_o - sin(phi_o)))
    y_i = (4 * r_i * sin(0.5 * phi_i)**3) / (3 * (phi_i - sin(phi_i)))

    # Calculate neutral bending plane y_bar
    y= (y_o * A_o - y_i * A_i) / (A_o - A_i)
    y_bar = abs(y)

    return y_bar




# find y for inner tube and outer tube
y_i_bar = calculate_ybar(g_i, IR_i, OR_i)
y_o_bar = calculate_ybar(g_o, IR_o, OR_o)
print("y_i_bar:",y_i_bar,"y_o_bar:", y_o_bar)
y_i = y_i_bar*cos(phi_i)
y_o = y_o_bar*cos(phi_o)
print("y_i:",y_i,"y_o:", y_o)



# # assume constant tau
# # q and kappa correlation
# d = y_i_bar + y_o_bar 
# q_total = 10 # TABLE II (paper2)
# q = q_total / n

# segment outer curvature, k_o_j
def calculate_k_o(q,d,h):
    k_o_j = q / (d * h) # [1/mm]
    return k_o_j# constant curvature in opposite direction
# k_o_j = calculate_k_o(q,d,h)
# curvatures_o = k_o_j * cos(phi_o)
# # print(curvatures_o)
d = y_i_bar + y_o_bar 
def update(val):
    q_total = q_slider.val
    q = q_total / n 
    curvatures_o = calculate_k_o(q,d,h) * cos(phi_o)
    x, z = calculate_curve_coordinates(L_curve,n, c, h, curvatures_o)
    plt.plot(x, z, label="Curve with Non-Constant Curvature")
    # plt.plot(x_test, z_test, label="test")
    plt.xlabel("X coordinate (mm)")
    plt.ylabel("Z coordinate (mm)")
    plt.title("Curve with Alternating Non-Constant Curvature (2:1 ratio)")
    plt.axis('equal')
    plt.legend()
    return x, z

def curvature(s, n, shape, c, h):
    segment_length = c + h 
    segment_index = int(s // segment_length) # current segment
    segment_index = min(segment_index, n - 1) # array bounds
    # Return the corresponding curvature
    return shape[segment_index]

def calculate_curve_coordinates(total_length, n, c, h, curvatures_o):
    # Generate a list of s values (arc length along the curve)
    s_values = np.linspace(0, total_length, n + 1)

    # Compute the curvature for each s value
    k_values = np.array([curvature(s, n, curvatures_o, c, h) for s in s_values])

    # Integrate curvature to get the turning angles
    angles = cumtrapz(k_values, s_values, initial=0)

    # Integrate the angles to get the coordinates of the curve
    x = cumtrapz(np.sin(angles), s_values, initial=0)
    z = cumtrapz(np.cos(angles), s_values, initial=0)

    return x, z

# Plotting the curve
plt.figure(figsize=(10, 6))


# p value slider
from matplotlib.widgets import Slider
q_slider_ax = plt.axes([0.15, 0.02, 0.65, 0.03])
q_slider = Slider(q_slider_ax, 'Tube base displacement, q', -17, 17, valinit=0)
q_slider.on_changed(update)

# # plt.plot(x_test, z_test, label="test")
# plt.xlabel("X coordinate (mm)")
# plt.ylabel("Z coordinate (mm)")
# plt.title("Curve with Alternating Non-Constant Curvature (2:1 ratio)")
# plt.axis('equal')
# plt.legend()
plt.grid(True)
plt.show()
