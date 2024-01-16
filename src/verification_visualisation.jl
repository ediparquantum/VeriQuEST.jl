
function two_pi_x()
    ([0,π/4,π/2,3*π/4,π,5*π/4,3*π/2,7*π/4,2*π],["0","π/4","π/2","3π/4","π","5π/4","3π/2","7π/4","2π"])
end

function ok_abort_y()
    ([0.0,1.0],["Abort","Ok"])
end

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

