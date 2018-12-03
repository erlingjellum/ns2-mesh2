#package require tooltip

set PARAMS_FILE_NAME "params2.txt"
set NS_EXEC_PATH "~/root/ns-allinone-2.35/ns-2.35/nstk"


# First open params.txt and read all parameters that were set by the GUI
set fp [open $PARAMS_FILE_NAME r]
set params [read $fp]
close $fp

set param_line [split $params "\n"]

set i 0;

set param(num_nodes_x)  [lindex $param_line $i]
set param(num_nodes_y)  [lindex $param_line [incr i]]
set param(num_nodes)    [lindex $param_line [incr i]]
set param(spacing_m)    [lindex $param_line [incr i]]
set param(master_index) [lindex $param_line [incr i]]
set param(jitterMax_ms) [lindex $param_line [incr i]] 
set param(advertisement_interval_ms) [lindex $param_line [incr i]]
set param(clock_drift) [lindex $param_line [incr i]]
set param(ttl) [lindex $param_line [incr i]]
set param(n_packets) [lindex $param_line [incr i]]
set param(mode) [lindex $param_line [incr i]]
set param(bandwidth) [lindex $param_line [incr i]]
set param(TX_power) [lindex $param_line [incr i]]
set param(node_env) [lindex $param_line [incr i]]
set param(show_nam) [lindex $param_line [incr i]]
set param(node_type) [lindex $param_line [incr i]]

set param(adv_roles) 1
set param(retransmissions) 1
set param(priority) "Original Packets"
set param(allow_rx_postpone) "No"

set param(node_cache_size) [lindex $param_line [incr i]]
set param(packet_payload_size) [lindex $param_line [incr i]]
set param(traffic_interval_ms) [lindex $param_line [incr i]]
set param(dead_time_us) [lindex $param_line [incr i]]
set param(node_relay) [split [lindex $param_line [incr i]] " "]
set param(traffic_generator) [split [lindex $param_line [incr i]] " "] 


global gui_progress
global .probar
set node_list {}
set node_select             "(0,0)"
set gui_progress            0
set relay [lindex $param(node_relay) 0]
set traffic_generator [lindex $param(traffic_generator) 0]


# Initialize the node_list (just for GUI)
for {set i 0} {$i < $param(num_nodes_y)} {incr i} {   
    for {set j 0} {$j < $param(num_nodes_x)} {incr j} {
        set index [expr $i*$param(num_nodes_x) + $j]
        lappend node_list "($i, $j)"  
    }
}


# set result variables
set res(n_packets) 0

global .
wm title . "BLE-Mesh Simulator v0.1"

# Menubar
menu .mbar
. configure -menu .mbar

menu .mbar.fl -tearoff 0
.mbar add cascade -menu .mbar.fl -label File -underline 0
.mbar.fl add command -label About... -command {open_about_window}
.mbar.fl add command -label Exit -command {exit}


# Progress bar
ttk::progressbar .probar -mode determinate -orient horizontal -length 100 -variable gui_progress

# Font
font create myFont -family Times -size 14 -weight bold

# ALL USER INPUT PARAMETERS
#####################################################

label .mode_label -font Myfont -text "Simulation Mode"
ttk::combobox .mode_entry -font myFont -font Myfont -textvariable  param(mode)\
                         -state readonly\
                          -values {"one-to-all" "all-to-one"}\
                          -state readonly
trace add variable param(mode) write update_mode

label .node_env_label -font Myfont -text "Node Environment" -justify left
ttk::combobox .node_env_entry -font Myfont -textvariable  param(node_env)\
                            -values {"Free-space"}\
                            -state readonly


label .show_nam_label -font Myfont -text "Show graphic visualization" -justify left
ttk::combobox .show_nam_entry -font Myfont -textvariable  param(show_nam)\
                                -state readonly\
                                -values {"Yes" "No"}

label .num_nodes_x_label -font Myfont -text "Node grid size x \[\]" -justify left
entry .num_nodes_x_entry  -font Myfont -textvariable  param(num_nodes_x)
trace add variable param(num_nodes_x) write update_node_list

label .num_nodes_y_label -font Myfont -text "Node grid size y \[\]" -justify left
entry .num_nodes_y_entry -font Myfont -textvariable  param(num_nodes_y)
trace add variable param(num_nodes_y) write update_node_list

label .spacing_label -font Myfont -text "Distance between nodes \[m\]" -justify left
entry .spacing_entry -font Myfont -textvariable  param(spacing_m)



label .traffic_interval_label -font Myfont -text "Traffic Generation Interval \[ms\]" -justify left
entry .traffic_interval_entry -font Myfont -textvariable  param(traffic_interval_ms) -justify left

label .txp_label -font Myfont -text "Advertisment Interval \[ms\]"
entry .txp_entry -font Myfont -textvariable  param(advertisement_interval_ms)

label .n_packets_label -font Myfont -text "Number of packets sent per node \[\]"
entry .n_packets_entry -font Myfont -textvariable  param(n_packets)

label .packet_size_label -font Myfont -text "Payload size \[Bytes\]" -justify left
entry .packet_size_entry -font Myfont -textvariable  param(packet_payload_size)

label .jitter_max_label -font Myfont -text "Max jitter \[ms\]" -justify left
entry .jitter_max_entry -font Myfont -textvariable  param(jitterMax_ms)



label .node_type_label -font Myfont -text "Node IC" -justify left
ttk::combobox .node_type_entry -font Myfont -textvariable  param(node_type)\
                                -state readonly\
                                -values {"nRF52"}

label .tx_power_label -font Myfont -text "TX power" -justify left
ttk::combobox .tx_power_entry -font Myfont -textvariable  param(TX_power)\
                                -state readonly\
                                -values {"-4dBm" "0dBm" "+4dBm"}

label .bw_label -font Myfont -text "Bandwidth" -justify left
ttk::combobox .bw_entry -font Myfont -textvariable  param(bandwidth)\
                        -state readonly\
                        -values {125kb 250kb 1Mb 2Mb}

label .ttl_label -font Myfont -text "TTL \[\]"
entry .ttl_entry -font Myfont -textvariable  param(ttl)

label .node_cache_size_label -font Myfont -text "Cache size \[n packets\]" -justify left
entry .node_cache_size_entry -font Myfont -textvariable  param(node_cache_size)


label .rx_dead_time_label -font Myfont -text "Radio Dead-time after receive \[us\]" -justify left
entry .rx_dead_time_entry -font Myfont -textvariable  param(dead_time_us) -justify left

label .clock_drift_label -font Myfont -text "Clock Drift \[ppm\]"
entry .clock_drift_entry -font Myfont -textvariable  param(clock_drift) -state readonly

label .retransmissions_label -font Myfont -text "Retransmissions"
entry .retransmissions_entry -font Myfont -textvariable  param(retransmissions) -state readonly

label .adv_roles_label -font Myfont -text "Advertisement Roles"
entry .adv_roles_entry -font Myfont -textvariable  param(adv_roles) -state readonly

label .priority_label -font Myfont -text "Priority"
entry .priority_entry -font Myfont -textvariable  param(priority) -state readonly

label .allow_rx_postpone_label -font Myfont -text "Allow RX to postpone Advertisement Window"
entry .allow_rx_postpone_entry -font Myfont -textvariable  param(allow_rx_postpone) -state readonly


label .node_select_label -font Myfont -text "Node" -justify left
ttk::combobox .node_select_entry -font Myfont -textvariable  node_select\
                                -values $node_list\
                                -state readonly
trace add variable node_select write update_node_options


label .node_master_label -font Myfont -text "Master" -justify left
checkbutton .node_master_button -command update_master

label .traffic_generator_label -font Myfont -text "Traffic Generator"
checkbutton .traffic_generator_button -variable traffic_generator
trace add variable traffic_generator write update_traffic_generators

label .node_relay_label -font Myfont -text "Relay" -justify left
checkbutton .node_relay_button -variable relay
trace add variable relay write update_node_relay


button .start_button -font Myfont -text "Start" -command "run_ns" 




# Configure the tool-tips for each label 
# tooltip::tooltip .jitter_max_label "The Transport Layer will add a random jitter to each packet"
# tooltip::tooltip .mode_label "one-to-all: One node, index specified by the parameter master, advertises to all other nodes in network \n all-to-one: All nodes except master advertises to the master."
# tooltip::tooltip .param(num_nodes_x_label) "Network layout is a grid. Specify the dimensions of the grid"
# tooltip::tooltip .num_nodes_y_label "Network layout is a grid. Specify the dimensions of the grid"
# tooltip::tooltip .spacing_label "The distant between two adjacent nodes in the grid"
# tooltip::tooltip .txp_label "The interval of advertisememt"
# tooltip::tooltip .n_packets_label "The number of advertisement packets to be sent by each advertiser during the simulation \n A higher number gives more accurate estimation"
# tooltip::tooltip .ttl_label "Time-To-Live for each packet. I.e. how many hops before the packet is dismissed"
# tooltip::tooltip .param(clock_drift_label) "The ppm clock drift for the nodes"
# tooltip::tooltip .master_index_label "The node index of the master node. One-To-All: Master = Advertiser. All-To-One: Master = Receiver\n The index is given as the position in the flattend out node matrix. For node (i,j) index = i*param(num_nodes_x) + j"
# tooltip::tooltip .disable_relay_index_label "Give a space separated list of the indices of the nodes that should, for any reason, not relay messages received\nIn BLE Mesh the standard is that all nodes relays all new packets, but this can saturate the channel and therefore, some nodes can be configured to not relay received packets." 



# Procedures for the TK GUI
###############################################################################3

# Procedure to call each time the dimensions of the grid has changed
# And we need to update the node_list and remake node relay lists and traffic generator lists
proc update_node_list {name1 name2 op} {
    global param node_list .node_select_entry 
    set node_list {}
    set param(node_relay) {}
    set param(traffic_generator) {}
    set param(num_nodes) [expr $param(num_nodes_x) * $param(num_nodes_y)]

    for {set i 0} {$i < $param(num_nodes_y)} {incr i} {
        for {set j 0} {$j < $param(num_nodes_x)} {incr j} {
            set index [expr $i*$param(num_nodes_x) + $j]
            lappend node_list "($i, $j)"
            if {$index != $param(master_index)} {
                lappend param(node_relay) 1
                lappend param(traffic_generator) 1    
            } else {
                lappend param(node_relay) 0
                lappend param(traffic_generator) 0
            }
            
        }

    .node_select_entry configure -font Myfont -textvariable  node_select\
                                -values $node_list\
                                -state readonly

    }

}


proc update_node_relay {name1, name2, op} {
    # Called when user checks/unchecks the button for relay
    global param relay node_select

    set ij [regexp -all -inline -- {[0-9]+} $node_select]
    set index [expr [lindex $ij 0]*$param(num_nodes_x) + [lindex $ij 1]]

    lset param(node_relay) $index $relay
}

proc update_traffic_generators {name1 name2 op} {
    #`Called when user checks/unchecks the button for traffic generator
    global param traffic_generator node_select

    set ij [regexp -all -inline -- {[0-9]+} $node_select]
    set index [expr [lindex $ij 0]*$param(num_nodes_x) + [lindex $ij 1]]

    lset param(traffic_generator) $index $traffic_generator
}

proc update_mode {name1 nam2 op} {
    # Called when user changes the "MODE". We need to disable traffic generator options
    global param .traffic_generator_button
    set param(traffic_generator) {}

    if {$param(mode) eq "one-to-all"} {
        .traffic_generator_button configure -state disabled
        for {set index 0} {$index < $param(num_nodes)} {incr index} {
            if {$index == $param(master_index)} {
                lappend param(traffic_generator) 1
            } else {
                lappend param(traffic_generator) 0
            }
        }
        

    } elseif {$param(mode) eq "all-to-one"} {
        .traffic_generator_button configure -state normal
        for {set index 0} {$index < $param(num_nodes)} {incr index} {
            if {$index == $param(master_index)} {
                lappend param(traffic_generator) 0
            } else {
                lappend param(traffic_generator) 1
            }
        }
        
    }
}

proc open_about_window {} {
    toplevel .a
    wm title .a "About"
    label .a.text -font Myfont -text "BLE Mesh Simulator\nVersion 0.1\nCopyright 2018 Nordic Semiconductor ASA\nSimulates a grid of BLE nodes running the BLE Mesh protocol with NS2" 

    grid .a.text
}



# Proc to call when we select a node and need to change the variable that thelse {
# Master checkbutton and the relay checkbutton are connected to
proc update_node_options {name1 nam2 op} {
    global node_select param .node_relay_button .node_master_button .traffic_generator_button
    set ij [regexp -all -inline -- {[0-9]+} $node_select]
    set index [expr [lindex $ij 0]*$param(num_nodes_x) + [lindex $ij 1]]
    if {[lindex $param(node_relay) $index]} {
        .node_relay_button select
    } else {
        .node_relay_button deselect
    }

    if {[lindex $param(traffic_generator) $index]} {
        .traffic_generator_button select
    } else {
        .traffic_generator_button deselect
    }


    if {$param(master_index) == $index} {
        .node_master_button select
    } else {
        .node_master_button deselect
    }
}

proc update_master {} {
    global node_select param
    set ij [regexp -all -inline -- {[0-9]+} $node_select]
    set param(master_index) [expr [lindex $ij 0]*$param(num_nodes_x) + [lindex $ij 1]]

}

# Initialize input-parameter arrays
#update_node_list 1 2 3 
update_node_options 1 2 3 

# Configure the layout of the GUI 
######################################

set i 0

# Stupid HACK to create "blank" rows in the GUI for better readability
label .empty_label1
label .empty_label2
label .empty_label3


grid .mode_label    -row $i  -column 0
grid .mode_entry    -row $i  -column 1

grid .node_env_label -row [incr i] -column 0
grid .node_env_entry -row $i        -column 1


grid .show_nam_label -row [incr i] -column 0
grid .show_nam_entry -row $i -column 1

grid .num_nodes_x_label -row [incr i] -column 0
grid .num_nodes_x_entry -row $i -column 1
grid .num_nodes_y_label -row [incr i] -column 0
grid .num_nodes_y_entry -row $i -column 1
grid .spacing_label     -row [incr i] -column 0
grid .spacing_entry     -row $i -column 1

## Add space
grid .empty_label1       -row [incr i] -column 0

grid .traffic_interval_label -row [incr i] -column 0
grid .traffic_interval_entry -row $i    -column 1

grid .txp_label         -row [incr i] -column 0
grid .txp_entry         -row $i -column 1

grid .n_packets_label   -row [incr i] -column 0
grid .n_packets_entry   -row $i -column 1

grid .packet_size_label -row [incr i] -column 0
grid .packet_size_entry -row $i -column 1





grid .jitter_max_label  -row [incr i] -column 0
grid .jitter_max_entry  -row $i -column 1

## Add space
grid .empty_label2       -row [incr i] -column 0


grid .node_type_label -row [incr i] -column 0
grid .node_type_entry -row $i        -column 1

grid .tx_power_label -row [incr i] -column 0
grid .tx_power_entry -row $i        -column 1

grid .bw_label -row [incr i] -column 0
grid .bw_entry -row $i        -column 1


grid .ttl_label         -row [incr i] -column 0
grid .ttl_entry         -row $i -column 1

grid .node_cache_size_label -row [incr i] -column 0
grid .node_cache_size_entry -row $i        -column 1

grid .rx_dead_time_label -row [incr i] -column 0
grid .rx_dead_time_entry -row $i -column 1

grid .retransmissions_label -row [incr i] -column 0
grid .retransmissions_entry -row $i -column 1

grid .adv_roles_label -row [incr i] -column 0
grid .adv_roles_entry -row $i -column 1

grid .priority_label -row [incr i] -column 0
grid .priority_entry -row $i -column 1

grid .allow_rx_postpone_label -row [incr i] -column 0
grid .allow_rx_postpone_entry -row $i -column 1


# Add space
grid .empty_label3       -row [incr i] -column 0

grid .node_select_label -row [incr i] -column 0
grid .node_select_entry -row $i -column 1

grid .node_master_label -row [incr i] -column 0
grid .node_master_button -row $i -column 1

grid .traffic_generator_label -row [incr i] -column 0
grid .traffic_generator_button -row $i -column 1

grid .node_relay_label  -row [incr i] -column 0
grid .node_relay_button -row $i -column 1



grid .start_button   -row [incr i] -column 0
grid .probar          -row $i   -column 1


#########################################################
##############   SETUP AND SIMULATION ####################
##########################################################

proc run_ns {} {
    global param res a ns n f num_nodes gui_progress .

    # Make sure variables that are supposed to be floats, are indeed floats
    set param(advertisement_interval_ms) [expr 1.0 * $param(advertisement_interval_ms)]
    set param(jitterMax_ms) [expr 1.0 * $param(jitterMax_ms)]
    set param(spacing_m) [expr 1.0 * $param(spacing_m)]
    set param(traffic_interval_ms) [expr 1.0 * $param(traffic_interval_ms)]

    
    # Calculate total number of nodes in simulation
    set param(num_nodes) [expr $param(num_nodes_x)*$param(num_nodes_y)]

    #Write parameters to file
    write_params_to_file

    # Create a "Cancel" Button
    .start_button configure -font Myfont -text Abort -command restart

    set MESSAGE_PORT 42 ;# Advertisment message. All Agents are attached to this port of the node.
    # Setting up Pysical Layer properties

    if {$param(node_env) eq "office"} {
        # See nsnam2 documentation ch. 18.3.1
        
        Propagation/Shadowing set pathlossExp_ 2.0
        Propagation/Shadowing set std_db_ 4.0
        Propagation/Shadowing set dist0_ 1.0
        Propagation/Shadowing set seed_ 0

        set val(prop) [new Propagation/Shadowing]

    }

    if {$param(node_env) eq "Free-space"} {


        set val(prop) [new Propagation/FreeSpace]
        
    }


    # Capture Threshold. I.e. SNR 
    Phy/WirelessPhy set CPThresh_ 32.0

    # Receiver sensitivity. Using indep-tools/propagation/threshold.cc to find it
    Phy/WirelessPhy set RXThresh_ 9.27e-10
    
    # Antenna strength (0dbm = 1mW)
    if {$param(TX_power) eq "-4dBm"} {
        Phy/WirelessPhy set Pt_ 0.0004
    } elseif {$param(TX_power) eq "0dBm"} {
        Phy/WirelessPhy set Pt_ 0.001
    } elseif {$param(TX_power) eq "+4Bdm"} {
        Phy/WirelessPhy set Pt_ 0.0025
    }

    # Set receiver frequency BLE is 2.4-2.485Ghz
    Phy/WirelessPhy set freq_ 2.48e+09
    
    # Antenna parameters. Not changed
    # Antenna/OmniAntenna set X_ 0
    # Antenna/OmniAntenna set Y_ 0
    # Antenna/OmniAntenna set Z_ 1.5
    # Antenna/OmniAntenna set Gt_ 1
    # Antenna/OmniAntenna set Gr_ 1

    # LinkLayer parameters, not touched
    LL set mindelay_                0
    LL set delay_                   0
    LL set bandwidth_               $param(bandwidth)       ;# not used
    DelayLink set bandwidth_        $param(bandwidth)
    DelayLink set delay_ 0

    # Mac-layer parameters
    # Set jitter to the Mac Layer
    Mac/SimpleMesh set jitter_max_us_ [expr int($param(jitterMax_ms)*1000)]
    Mac set bandwidth_ 1000000
    Mac/SimpleMesh set bandwidth_ 1000000
    


    set val(chan)           Channel/WirelessChannel    ;#Channel Typevar
    set val(netif)          Phy/WirelessPhy            ;# network interface type
    set val(energy)         "EnergyModel"
    set val(mac)		    Mac/SimpleMesh
    set val(ifq)            Queue/DropTail             ;# interface queue type
    set val(ll)             LL                  ;# link layer type
    set val(ant)            Antenna/OmniAntenna        ;# antenna model
    set val(ifqlen)         50                         ;# max packet in ifq
    set val(rxPower)        0.00001 ;# not important
    set val(txPower)        0.001;#Not important
    set val(initialEnergy)  0.1; #Not important
    set val(rp)             DumbAgent

    set val(size_x)              [expr $param(num_nodes_x) * $param(spacing_m)]
    set val(size_y)              [expr $param(num_nodes_y) * $param(spacing_m)]


    # Create topography
    set topo [new Topography]
    $topo load_flatgrid $val(size_x) $val(size_y)

    # Create General Operations Director
    create-god $param(num_nodes) 

    # Create Simulator object
    set ns [new Simulator]
    set f [open simple-adv.tr w]

    if {$param(show_nam) eq "Yes"} {
        set nf [open ble-mesh.nam w]
        $ns namtrace-all-wireless $nf $val(size_x) $val(size_y)      
    }
    

    $ns trace-all $f


    # Set default node-config
    $ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propInstance $val(prop)\
                -phyType $val(netif) \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace OFF \
                -macTrace ON \
                -movementTrace OFF \
                -channel [new $val(chan)] \
                #-energyModel $val(energy) \
                #-rxPower $val(rxPower) \
                #-txPower $val(txPower)\
                #-initialEnergy $val(initialEnergy)

    # Creating all nodes
    for {set i 0} {$i < $param(num_nodes_y)} {incr i} {
        for {set j 0} {$j < $param(num_nodes_x)} {incr j} {
            set index [expr ($i*$param(num_nodes_x))+$j];#calculate index in 1-D node array

            # Setup MAC layer stuff
            Mac/SimpleMesh set adv_interval_us_ [expr $param(advertisement_interval_ms) * 1000]
            Mac/SimpleMesh set retransmissions_ 1
            Mac/SimpleMesh set adv_roles_ $param(adv_roles)
            Mac/SimpleMesh set dead_time_us_ $param(dead_time_us)


            set n($index) [$ns node];# New node object
            
            # Set the physical position of the node, only based on spacing
            $n($index) set X_ [expr $param(spacing_m)*$j];
            $n($index) set Y_ [expr $param(spacing_m)*$i];
            $n($index) set Z_ 0
            $ns initial_node_pos $n($index) 2
            
            # Attach Transport Protocol Layer to each node
            set a($index) [new Agent/BleMeshAdv]
            $a($index) sett ttl $param(ttl)
            #$a($index) set clockDrift_ppm_ [expr floor(rand()*$param(clock_drift))]
            $n($index) attach $a($index) $MESSAGE_PORT

            # Set the cache-size
            $a($index) sett cache-size $param(node_cache_size)

            # Set node-id
            $a($index) sett node-id $index

            # Set packet size
            $a($index) set packetSize_ [expr 121 + ($param(packet_payload_size) * 8)] 

            # Set relay
            # Set node-specific properties
            if {[lindex $param(node_relay) $index]} {
                $a($index) set relay_ 1 ;#Relay is on
            } else {
                $a($index) set relay_ 0 ;#Relay is off
            }
        }
    
    }



    # Setting up the advertisement packages

    if {$param(mode) eq "one-to-all"} {
        puts "ONE-TO-ALL"

        for {set i 0} {$i < $param(n_packets)} {incr i} {
            $ns at [expr $i*$param(traffic_interval_ms)/1000] "$a($param(master_index)) schedule-adv $i"
        }

        for {set j 0} {$j < [expr $param(num_nodes) ]} {incr j} {
            # Start advertisement
            $ns at 0.0 "$a($j) start-adv"
        }
            
      


    } elseif {$param(mode) eq "all-to-one"} {
        puts "ALL-TO-ONE"
        #for {set index 0} {$index < $param(num_nodes)} {incr index} {
        #    set offset($index) [expr rand() * $param(advertisement_interval_ms)/1000]
        #}

        for {set i 0} {$i < $param(n_packets)} {incr i} {
            for {set j 0} {$j < [expr $param(num_nodes) ]} {incr j} {
                # Check that this is a traffic generating node
                if {[lindex $param(traffic_generator) $j]} { 
                    $ns at [expr $i*$param(traffic_interval_ms)/1000] "$a($j) schedule-adv [expr $i*$param(num_nodes) + $j]"
                }
            }
        }

        for {set j 0} {$j < [expr $param(num_nodes) ]} {incr j} {
            # Start advertisement
            if {$j != $param(master_index)} {
                $ns at 0.0 "$a($j) start-adv"
            }
            
        }



    }

    # Finish simulation at the time guaranteed to be past all events
    set param(tot_time) [expr $param(n_packets)*$param(traffic_interval_ms)/1000]
    $ns at $param(tot_time) finish

    # Create events for updating the progressbar
    for {set index 1} {$index < 101} {incr index} {
        $ns at [expr ($index * $param(n_packets) * $param(traffic_interval_ms)/100000)] update_progressbar
    }

    # Procedure to be called after Simulation is done.
    proc finish {} {
        global ns n f a param .
        $ns halt
        $ns flush-trace
        close $f
        
        # Disable the buttons and inputs  to inhibit reruns with the current run tim simulator
        disable_gui
        .start_button configure -font Myfont -text "New Simulation" -command restart

        toplevel .f
        wm title .f "Simulation results"
        tk::listbox .f.text -font Myfont -yscrollcommand ".f.scroll set" -height 50 -width 100
         #Make a scrollbar
        scrollbar .f.scroll -command ".f.text yview" -orient vertical 


        .f.text insert end "SIMULATION PARAMETERS:"
        .f.text insert end "num_nodes_x = $param(num_nodes_x)"
        .f.text insert end "num_nodes_y = $param(num_nodes_y)"
        .f.text insert end "Spacing between nodes = $param(spacing_m)"
        .f.text insert end "Index of master = $param(master_index)"
        .f.text insert end "jitterMax = $param(jitterMax_ms)"
        .f.text insert end "Traffic generation interval = $param(traffic_interval_ms)"
        .f.text insert end "Advertisement interval = $param(advertisement_interval_ms)"
        .f.text insert end "Clock Drift = $param(clock_drift)"
        .f.text insert end "n_packets = $param(n_packets)"
        .f.text insert end "Mode = $param(mode)"
        .f.text insert end "Bandwidth = $param(bandwidth)"
        .f.text insert end "TX Power = $param(TX_power)"
        .f.text insert end "Node environment = $param(node_env)"


        if {$param(mode) eq "one-to-all"} {
            # Open a new GUI window to display the results
            

            set total_success 0
            array set packets_per_link {}

            for {set i 0} {$i < [expr $param(num_nodes_x)*$param(num_nodes_y)]} {incr i} {
                set packets_per_link($i) [$a($i) set packets_received_]
                set total_success [expr $total_success + $packets_per_link($i)]
            }


            # Format the results to output it on the GUI
            
            .f.text insert end "SIMULATION RESULTS:"
            .f.text insert end "Total successful packets from master = $total_success/[expr $param(n_packets)*($param(num_nodes_x)*$param(num_nodes_y)-1)]"
            .f.text insert end "Total Bandwidth from master =  [expr $total_success*$param(packet_payload_size)*8/($param(traffic_interval_ms)*$param(n_packets))] kbps"

            for {set i 0} {$i < [expr $param(num_nodes_x)*$param(num_nodes_y)]} {incr i} {
                .f.text insert end "Master->Node_$i $packets_per_link($i)/$param(n_packets) packets received, Bandwidth = [expr $packets_per_link($i)*$param(packet_payload_size)*8/($param(traffic_interval_ms)*$param(n_packets))] kbps\n"
            }
                


        } elseif {$param(mode) eq "all-to-one"} {
            set pkts_recvd [$a($param(master_index)) set packets_received_]
            set test 0
            set mac [$n($param(master_index)) set mac_(0)]

            .f.text insert end "SIMULATION RESULTS:"
            .f.text insert end "## Gateway ##"
            .f.text insert end "Packets received = $pkts_recvd/[expr $param(n_packets)*($param(num_nodes_x)*$param(num_nodes_y)-1)]"
            .f.text insert end "Throughput =  [expr $pkts_recvd*$param(packet_payload_size)*8/($param(tot_time)*1000)] kbps\n"
            .f.text insert end "Duplicates received = [$a($param(master_index)) get duplicates-received]"
            .f.text insert end  "CRC-Collision = [$mac get crc-collisions] Co-Channel-Rejections = [$mac get co-channel-rejections] Dead-Time-Collisions: [$mac get dead-time-collisions]"

            for {set index 0} {$index < $param(num_nodes)} {incr index} {
                if {$index != $param(master_index)} {   
                    # Get reference to MAC layer to get out some stats
                    set mac [$n($index) set mac_(0)]

                    set pkts_recvd [$a($param(master_index)) get packets-received-from-node $index]
                    set test [expr $test + $pkts_recvd]
                    .f.text insert end "## Node_$index ##"
                    .f.text insert end  "Packets successfully received at Gateway = $pkts_recvd/$param(n_packets)"
                    .f.text insert end  "Throughput = [expr $pkts_recvd*$param(packet_payload_size)*8/($param(tot_time)*1000)] kbps"
                    .f.text insert end  "Packet queue length at the end of simulation =  [$mac get send-queue]"
                    .f.text insert end  "Relayed packets = [$mac get relays] Cache-misses = [$a($index) get cache-misses]"
                    .f.text insert end  "CRC-Collision = [$mac get crc-collisions] Co-Channel-Rejections = [$mac get co-channel-rejections] Dead-Time-Collisions: [$mac get dead-time-collisions]"
            
                }
            }
        } 

            grid .f.text -sticky nwes -column 0 -row 0
            grid .f.scroll -column 1 -row 0 -sticky ew

        if {$param(show_nam) eq "Yes"} {
            exec  /root/ns-allinone-2.35/nam-1.15/nam /root/ns2-mesh2/ble-mesh.nam &    
        }

        

        
        
    }

    proc update_progressbar {} {
        global gui_progress
        incr gui_progress
        update idletasks
        update


    }

    $ns run
}

proc restart {} {
    global NS_EXEC_PATH
    exec /root/ns-allinone-2.35/ns-2.35/nstk /root/ns2-mesh2/learn2.tcl &
    exit 0
}   

proc disable_gui {} {
    global .
    .mode_entry configure -state disabled  
    .show_nam_entry configure -state disabled
    .node_env_entry configure -state disabled
    .node_type_entry configure -state disabled
    .num_nodes_x_entry configure -state disabled 
    .num_nodes_y_entry configure -state disabled
    .spacing_entry configure -state disabled    
    .n_packets_entry configure -state disabled 
    .txp_entry configure -state disabled
    .jitter_max_entry configure -state disabled
    .tx_power_entry configure -state disabled
    .bw_entry configure -state disabled
    .node_cache_size_entry configure -state disabled
    .ttl_entry configure -state disabled
    .clock_drift_entry configure -state disabled
    .node_select_entry configure -state disabled
    .node_relay_button configure -state disabled
    .node_master_button configure -state disabled
    .packet_size_entry configure -state disabled
    .traffic_interval_entry configure -state disabled
    .rx_dead_time_entry configure -state disabled
    .traffic_generator_button configure -state disabled
    .allow_rx_postpone_entry configure -state disabled
    .retransmissions_entry configure -state disabled
    .adv_roles_entry configure -state disabled
    .priority_entry configure -state disabled
}    


proc write_params_to_file {} {

    global param PARAMS_FILE_NAME

    set fp [open $PARAMS_FILE_NAME w]

    puts $fp $param(num_nodes_x)            
    puts $fp $param(num_nodes_y)
    puts $fp $param(num_nodes)                         
    puts $fp $param(spacing_m)              
    puts $fp $param(master_index)           
    puts $fp $param(jitterMax_ms)            
    puts $fp $param(advertisement_interval_ms)  
    puts $fp $param(clock_drift)            
    puts $fp $param(ttl)                     
    puts $fp $param(n_packets)              
    puts $fp $param(mode)                   
    puts $fp $param(bandwidth)              
    puts $fp $param(TX_power)               
    puts $fp $param(node_env)               
    puts $fp $param(show_nam)               
    puts $fp $param(node_type)              
    puts $fp $param(node_cache_size)  
    puts $fp $param(packet_payload_size)
    puts $fp $param(traffic_interval_ms) 
    puts $fp $param(dead_time_us)     

    for {set index 0} {$index < $param(num_nodes)} {incr index} {
        puts -nonewline $fp [lindex $param(node_relay) $index]
        puts -nonewline $fp " "
    }

    puts -nonewline $fp "\n"
    for {set index 0} {$index < $param(num_nodes)} {incr index} {
        puts -nonewline $fp [lindex $param(traffic_generator) $index]
        puts -nonewline $fp " "


    }

    close $fp

}
############################################################################






    


