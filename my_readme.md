
sudo apt update
sudo apt upgrade -y
sudo apt install language-pack-zh-hans -y
​4. 安装中文输入法引擎​​

    ​​搜狗拼音输入法​​（推荐，需手动下载）
    下载适用于Ubuntu 20.04的.deb包（官网

），然后安装：

sudo apt install ./sogoupinyin_*.deb -y



wget http://fishros.com/install -O fishros && . fishros



sudo apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE

sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u

sudo apt-get install librealsense2-utils \
                     librealsense2-dev \
                     librealsense2-dbg -y
                     
realsense-viewer #测试相机
                     
sudo apt-get install ros-noetic-realsense2-*







sudo apt-get install build-essential libgtk2.0-dev libjpeg-dev  libtiff5-dev libopenexr-dev libtbb-dev
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libgtk-3-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev pkg-config





git clone --branch arch-arm64 --depth 1 https://github.com/nelvko/clash-for-linux-install.git \
  && cd clash-for-linux-install \
  && sudo bash install.sh







sudo apt purge libopencv-dev libopencv4.2-java libopencv4.2-jni
sudo apt autoremove
cd opencv-3.4/
mkdir build
cd build
cmake ..
sudo make -j4


好的，以下是完整的中文版 `README.md` 文件，包含了所有步骤和说明，用于在 Ubuntu 20.04 上安装 **OpenCV 3** 和 **OpenCV 4**（ROS Noetic 默认版本），并且让 `cv_bridge` 同时支持这两个版本的 OpenCV。

---

# OpenCV 3 和 ROS Noetic 多版本共存配置

本指南将指导您在 Ubuntu 20.04 上安装 **OpenCV 3** 和 **OpenCV 4**（ROS Noetic 默认版本），并配置 `cv_bridge` 使其能够同时支持这两个版本的 OpenCV。目的是让多个 OpenCV 版本在系统中共存而不会破坏现有的 ROS Noetic 设置。

### 前提条件

* Ubuntu 20.04
* ROS Noetic（默认 OpenCV 4.x）
* 对终端命令和从源代码编译的基本了解

### 0. 安装 OpenCV 依赖项

首先，更新系统并安装编译 OpenCV 所需的依赖项。

```bash
sudo apt update
sudo apt-get install build-essential cmake git pkg-config libavcodec-dev libavformat-dev libswscale-dev libatlas-base-dev gfortran zlib1g-dev ccache autoconf automake libtool checkinstall
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
sudo apt update
sudo apt install libjasper1 libjasper-dev
sudo apt-get install libjpeg-dev libjpeg8-dev libtiff5-dev libjasper-dev libpng-dev
sudo apt install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
```

### 1. 编译 OpenCV 3 及其 contrib 库

#### 1.1 下载 OpenCV 3 源代码

首先，克隆 OpenCV 仓库并切换到 **3.4.14** 版本：

```bash
git clone https://github.com/opencv/opencv.git -b 3.4.14
mv opencv opencv3.4.14
cd opencv3.4.14
```

#### 1.2 下载 OpenCV Contrib 模块

然后，克隆 OpenCV contrib 仓库，确保它与 OpenCV 版本匹配：

```bash
git clone https://github.com/opencv/opencv_contrib.git -b 3.4.14
```

#### 1.3 配置 OpenCV 编译选项

创建一个 build 目录，并使用 `cmake` 配置 OpenCV 编译选项：

```bash
cd ../
mkdir build
cd build
cmake -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DWITH_TBB=ON \
      -DWITH_V4L=ON \
      -DCMAKE_INSTALL_PREFIX=/usr/local/opencv3.4.14 \
      -DBUILD_opencv_vtk=OFF \
      -DWITH_VTK=OFF \
      ..
```

#### 1.4 解决依赖问题

在执行 `cmake` 配置时，您可能会遇到缺少的依赖项（例如缺少 `PythonLibs`、`gstreamer-base` 或 `ccache`）。可以通过以下命令安装它们：

```bash
sudo apt-get install python-dev
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get install ccache
sudo apt-get install liblapack-dev liblapacke-dev libopenblas-dev
sudo apt install default-jdk
```

所有依赖项安装完后，编译 OpenCV 3：

```bash
make -j12
sudo make install
```

### 2. 安装适配 OpenCV 3 的 `cv_bridge`

#### 2.1 下载 `cv_bridge` 源代码

为了支持 OpenCV 3，我们需要从 `vision_opencv` 仓库下载适配于 ROS Melodic 的 `cv_bridge`：

```bash
cd ~/catkin_ws/src
git clone https://github.com/ros-perception/vision_opencv.git
cd vision_opencv
git checkout melodic-devel
```

#### 2.2 修改 `CMakeLists.txt` 以支持 OpenCV 3

进入 `vision_opencv-melodic/cv_bridge` 目录，修改 `CMakeLists.txt` 文件，以确保它能够正确找到 OpenCV 3 的路径。

在文件开头添加以下内容：

```cmake
cmake_minimum_required(VERSION 2.8)
project(cv_bridge)

# 添加下面的内容，设置 OpenCV 3 路径
set(OpenCV_DIR /usr/local/opencv3.4.14/share/OpenCV)
set(OpenCV_INCLUDE_DIRS "/usr/local/opencv3.4.14/include")
set(OpenCV_LIBRARIES "/usr/local/opencv3.4.14/lib")
```

接着找到以下代码，并修改为不区分 Python 版本，这样可以避免编译时找不到 `boost_python3` 的问题：

```cmake
if(NOT ANDROID)
  find_package(PythonLibs)
  if(PYTHONLIBS_VERSION_STRING VERSION_LESS 3)
    find_package(Boost REQUIRED python)
  else()
    find_package(Boost REQUIRED python3)
  endif()
else()
  find_package(Boost REQUIRED)
endif()
```

修改为：

```cmake
if(NOT ANDROID)
  find_package(PythonLibs)
  find_package(Boost REQUIRED python)
else()
  find_package(Boost REQUIRED)
endif()
```

保存并退出文件。

#### 2.3 编译并安装 `cv_bridge`

在 `vision_opencv-melodic/cv_bridge` 目录中创建构建目录并编译 `cv_bridge`：

```bash
cd vision_opencv-melodic/cv_bridge
mkdir build
cd build
cmake ..
make -j12
```

安装 `cv_bridge`：

```bash
sudo make install DESTDIR=/usr/local/cv_bridge_melodic
```

### 3. 修改 ROS 包中的 `CMakeLists.txt` 来指定 OpenCV 和 `cv_bridge` 版本

在 ROS 包的 `CMakeLists.txt` 文件中设置 OpenCV 和 `cv_bridge` 的链接路径：

```cmake
# 在 project(xxx) 后面添加以下两行
set(cv_bridge_DIR /usr/local/cv_bridge_melodic/usr/local/share/cv_bridge/cmake)
set(OpenCV_DIR /usr/local/opencv3.4.14/share/OpenCV)
```

### 4. 测试和验证

完成上述步骤后，您应该可以在 ROS 中同时使用适配于 OpenCV 3 的 `cv_bridge` 和系统自带的 `cv_bridge`（链接到 OpenCV 4）。运行您的 ROS 程序，确保没有出现任何错误，且图像转换功能正常。

---

这就是如何在不删除 OpenCV 4 的情况下，在 ROS Noetic 环境中同时使用 OpenCV 3 和 `cv_bridge` 的方法。如果您有任何问题或需要进一步的帮助，随时告诉我！





sudo apt-get install libceres-dev

easy@ubuntu:~/easy_mav_ws/vins_ws$ roslaunch vins my_camera.launch 
easy@ubuntu:~/easy_mav_ws/vins_ws$ roslaunch vins vins_rviz.launch 

rosrun vins vins_node /home/easy/easy_mav_ws/vins_ws/src/VINS-Fusion/config/realsense_d435i/realsense_stereo_imu_config.yaml  
rosrun loop_fusion loop_fusion_node /home/easy/easy_mav_ws/vins_ws/src/VINS-Fusion/config/realsense_d435i/realsense_stereo_imu_config.yaml  

/camera/depth/image_rect_raw
/camera/color/image_raw