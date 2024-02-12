
"""
    two_pi_x()

Generates a tuple of two arrays representing the radian values and their string representations from 0 to 2π with a step of π/4.

# Returns
- A tuple of two arrays. The first array contains the radian values from 0 to 2π with a step of π/4. The second array contains the string representations of these radian values.

# Examples
```julia    
radians, labels = two_pi_x()
```
"""
function two_pi_x()
    ([0,π/4,π/2,3*π/4,π,5*π/4,3*π/2,7*π/4,2*π],["0","π/4","π/2","3π/4","π","5π/4","3π/2","7π/4","2π"])
end


"""
    ok_abort_y()

Generates a tuple of an array of two float values and an array of two string values "Abort" and "Ok".

# Returns
- A tuple of two arrays. The first array contains the float values [0.0, 1.0]. The second array contains the string values ["Abort", "Ok"].

# Examples
```julia    
values = ok_abort_y()
```
"""
function ok_abort_y()
    ([0.0,1.0],["Abort","Ok"])
end

"""
    plot_verification_results(::MaliciousServer, ::Verbose, xdata, ydata, label)

Generates a bar plot of verification results for a MaliciousServer in a Verbose mode. The function normalizes the y-data, creates a figure and an axis, plots the data, adds a legend, and returns the figure.

# Arguments
- `::MaliciousServer`: An instance of `MaliciousServer`.
- `::Verbose`: An instance of `Verbose`.
- `xdata`: An array of x-data for the plot.
- `ydata`: An array of y-data for the plot.
- `label`: A string to be used as the label in the legend.

# Returns
- A Figure object containing the generated plot.

"""
function plot_verification_results(::MaliciousServer,::Verbose,xdata,ydata,label)
    ∑ydata = sum(ydata)
    normy = ydata ./ ∑ydata
    f = Figure(resolution = (1200,1200),fontsize = 35)
    ax = Axis(
        f[1,1],
        xlabel = "Angle",
        ylabel = "Failed Rounds", 
        title = "Malicious Server Verification Results", 
        subtitle = "Inserts an additional angle to measurement basis",
        xticks = two_pi_x(),aspect=1)
    results_scatter = barplot!(ax,xdata,Float64.(normy))
    Legend(f[2,1],
    [results_scatter],[label],
    orientation=:horizontal,halign=:left)
    f
end


"""
    plot_verification_results(::MaliciousServer, ::Terse, xdata, ydata, label)

Generates a scatter plot of verification results for a MaliciousServer in a Terse mode. The function creates a figure and an axis, plots the data, adds a legend, and returns the figure.

# Arguments
- `::MaliciousServer`: An instance of `MaliciousServer`.
- `::Terse`: An instance of `Terse`.
- `xdata`: An array of x-data for the plot.
- `ydata`: An array of y-data for the plot.
- `label`: A string to be used as the label in the legend.

# Returns
- A Figure object containing the generated plot.

"""
function plot_verification_results(::MaliciousServer,::Terse,xdata,ydata,label)
    f = Figure(resolution = (1200,1200),fontsize = 35)
    ax = Axis(
        f[1,1],
        xlabel = "Angle",
        ylabel = "Round Outcome", 
        title = "Malicious Server Verification Results", 
        subtitle = "Inserts an additional angle to measurement basis",
        xticks = two_pi_x(),
        yticks = ok_abort_y(),aspect=1)
    results_scatter = scatter!(ax,xdata,Float64.(ydata))
    Legend(f[2,1],
    [results_scatter],[label],
    orientation=:horizontal,halign=:left)
    f
end

