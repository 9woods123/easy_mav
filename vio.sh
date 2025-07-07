#!/bin/bash

# 启动 mavros
gnome-terminal --tab --title="MAVROS" -- bash -c "cd ~/easy_mav_ws/vins_ws; source devel/setup.bash; roslaunch vins px4.launch; exec bash" &

sleep 1

# 启动 Camera Launch
gnome-terminal --tab --title="Camera Launch" -- bash -c "cd ~/easy_mav_ws/vins_ws; source devel/setup.bash; roslaunch vins my_camera.launch; exec bash" &

sleep 2

# 启动 RViz
gnome-terminal --tab --title="RViz" -- bash -c "cd ~/easy_mav_ws/vins_ws; source devel/setup.bash; roslaunch vins vins_rviz.launch; exec bash" &

sleep 2

# 启动 VINS Node
gnome-terminal --tab --title="VINS Node" -- bash -c "cd ~/easy_mav_ws/vins_ws; source devel/setup.bash; rosrun vins vins_node ~/easy_mav_ws/vins_ws/src/VINS-Fusion/config/realsense_d435i/realsense_stereo_imu_config.yaml; exec bash"

