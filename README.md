# 🤖 ROS Code Checker & Simulation Preview Tool

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![ROS2](https://img.shields.io/badge/ROS2-Humble-blue.svg)](https://docs.ros.org/en/humble/index.html)
[![Python](https://img.shields.io/badge/Python-3.8+-yellow.svg)](https://www.python.org/)
[![Gazebo](https://img.shields.io/badge/Gazebo-11+-orange.svg)](https://gazebosim.org/)

A comprehensive system for validating ROS/ROS2 code packages, performing safety checks, and running robotic arm simulations in Gazebo. This tool helps developers ensure their ROS code is correct, safe, and functional before deployment.

## 📋 Table of Contents
- [Features](#features)
- [System Architecture](#system-architecture)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Test Packages](#test-packages)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

### Code Validation
- **Syntax Checking**: Python (flake8/ament_flake8) and C++ (g++ dry-run)
- **ROS Structure Validation**: Checks package.xml, CMakeLists.txt/setup.py
- **Node Detection**: Automatically detects publishers, subscribers, services
- **Safety Heuristics**: Validates joint limits, motion speeds, and safe programming patterns

### Simulation
- **Gazebo Integration**: Full UR5 robotic arm simulation
- **ROS2 Control**: Modern ros2_control framework
- **Real-time Monitoring**: Joint states and task completion tracking
- **Screenshot Capture**: Visual simulation results

### Web Interface
- **File Upload**: Easy ZIP package submission
- **Live Reports**: Real-time validation results
- **Simulation Control**: Start/stop simulations from browser
- **Visual Feedback**: View logs and simulation previews

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Web Interface (Flask)                    │
│                  Upload → Validate → Simulate                │
└─────────────────────┬───────────────────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │                         │
┌────────▼────────┐      ┌────────▼─────────┐
│  Code Checker   │      │  Sim Runner      │
│  - Syntax       │      │  - Gazebo        │
│  - Structure    │      │  - UR5 Control   │
│  - Safety       │      │  - Monitoring    │
└─────────────────┘      └──────────────────┘
```

## 🔧 Installation

### Prerequisites
- Ubuntu 22.04 LTS
- ROS2 Humble/Jazzy
- Python 3.8+
- Gazebo 11+

### System Dependencies

```bash
# Install ROS2
sudo apt update
sudo apt install ros-humble-desktop-full

# Install Gazebo and ROS2 Control
sudo apt install ros-humble-gazebo-ros-pkgs
sudo apt install ros-humble-ros2-control
sudo apt install ros-humble-ros2-controllers
sudo apt install ros-humble-gazebo-ros2-control

# Install UR robot packages
sudo apt install ros-humble-ur-simulation-gazebo
sudo apt install ros-humble-ur-robot-driver

# Install development tools
sudo apt install python3-flake8
sudo apt install python3-colcon-common-extensions
sudo apt install python3-pip
```

### Python Dependencies

```bash
cd ros-code-checker-simulator
pip3 install -r requirements.txt
```

### Setup Script

```bash
chmod +x setup.sh
./setup.sh
```

## 🚀 Quick Start

### 1. Start the Web Interface

```bash
cd web_interface
python3 app.py
```

Open browser to `http://localhost:5000`

### 2. Upload a ROS Package

- Create a ZIP file of your ROS package
- Upload through web interface
- View validation results

### 3. Run Simulation

- Click "Run Simulation" after successful validation
- Monitor progress in real-time
- View results and screenshots

## 📖 Usage

### Command Line Interface

#### Check Code Only

```bash
python3 backend/code_checker.py --input my_package.zip --output report.json
```

#### Run Simulation

```bash
python3 simulator/simulation_runner.py --package /path/to/package --duration 60
```

### Python API

```python
from backend.code_checker import check_ros_package
from simulator.simulation_runner import launch_gazebo_simulation

# Validate package
results = check_ros_package('package.zip')

if results['passed']:
    # Run simulation
    sim_results = launch_gazebo_simulation(results['package_path'])
    print(f"Success: {sim_results['success']}")
```

## 📁 Project Structure

```
ros-code-checker-simulator/
├── README.md
├── requirements.txt
├── setup.sh
│
├── backend/                    # Validation engine
│   ├── code_checker.py        # Main checker
│   ├── ros_validator.py       # ROS structure validation
│   ├── syntax_checker.py      # Syntax validation
│   ├── safety_checker.py      # Safety heuristics
│   └── report_generator.py    # Report generation
│
├── simulator/                  # Simulation engine
│   ├── simulation_runner.py   # Gazebo launcher
│   ├── gazebo_controller.py   # Simulation control
│   └── worlds/
│       └── ur5_pickplace.world # Gazebo world file
│
├── web_interface/             # Flask web app
│   ├── app.py                 # Main application
│   ├── static/
│   │   ├── css/style.css
│   │   └── js/script.js
│   └── templates/
│       ├── index.html
│       ├── results.html
│       └── simulation.html
│
├── test_packages/             # Example packages
│   ├── correct_package/       # Valid package
│   └── faulty_package/        # Invalid package
│
└── docs/                      # Documentation
    ├── SETUP.md              # Setup guide
    ├── USAGE.md              # Usage guide
    └── TESTING_LOGS.md       # Test results
```

## 🧪 Test Packages

Two test packages are included to demonstrate the tool's capabilities:

### 1. Correct Package (Pick-and-Place)

A fully functional ROS2 package that:
- Properly initializes a node
- Creates publishers for joint trajectory control
- Uses safe joint limits
- Implements proper timing with sleep
- Follows ROS2 best practices

**Expected Result**: All checks pass ✅

### 2. Faulty Package

A deliberately broken package with common errors:
- Missing node initialization
- Unsafe joint values (outside ±360°)
- Tight loops without sleep
- Missing package.xml dependencies
- Syntax errors

**Expected Result**: Multiple errors detected ❌

## 📊 Validation Checks

### Safety Checks for UR5

| Parameter | Safe Range | Check |
|-----------|------------|-------|
| Joint Position | ±360° (±6.28 rad) | ✓ |
| Joint Speed | ≤180°/s (3.14 rad/s) | ✓ |
| Payload | ≤5 kg | ✓ |
| Loop Rate | ≥10 Hz (with sleep) | ✓ |

### ROS Structure Checks

- ✅ package.xml exists and is valid XML
- ✅ CMakeLists.txt or setup.py present
- ✅ Dependencies properly declared
- ✅ Node entry points configured
- ✅ Launch files syntax correct

### Code Quality Checks

- ✅ Python: PEP 8 compliance (flake8)
- ✅ C++: Compilation check (g++)
- ✅ ROS patterns: init_node detected
- ✅ Topic names follow conventions
- ✅ No obvious memory leaks

## 📝 Documentation

Detailed documentation is available in the `docs/` directory:

- **[SETUP.md](docs/SETUP.md)**: Complete installation and configuration guide
- **[USAGE.md](docs/USAGE.md)**: Detailed usage instructions and examples
- **[TESTING_LOGS.md](docs/TESTING_LOGS.md)**: Test results and performance metrics

## 🎬 Demo Video

A 2-minute demonstration video showing:
1. Uploading and validating a correct package
2. Running the Gazebo simulation with UR5
3. Uploading a faulty package and viewing errors
4. Explanation of validation reports

**Coming soon!** Check the releases for the video link.

## 👥 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow ROS2 coding standards
- Add tests for new features
- Update documentation
- Use meaningful commit messages

## 🛠️ Technologies Used

- **ROS2 Humble/Jazzy**: Robot Operating System
- **Gazebo**: 3D robot simulator
- **Flask**: Web framework
- **Python 3.8+**: Backend language
- **JavaScript/HTML/CSS**: Frontend
- **flake8**: Python linting
- **ament tools**: ROS2 build tools

## 📚 References

This project is based on industry best practices:

- [ROS2 Documentation](https://docs.ros.org/en/humble/)
- [Gazebo Tutorials](https://gazebosim.org/docs)
- [UR5 Robot Manual](https://www.universal-robots.com/)
- [ROS2 Control Framework](https://control.ros.org/)

## ❓ FAQ

**Q: Which ROS versions are supported?**
A: ROS2 Humble and Jazzy are fully supported. ROS1 packages can be validated but simulation requires ROS2.

**Q: Can I use other robot models?**
A: Yes! The system can be extended to support Franka Emika Panda, KUKA, ABB, and other models.

**Q: Does it work with Docker?**
A: Docker support is planned. Currently, native installation is recommended.

**Q: How long does validation take?**
A: Typical packages validate in 5-10 seconds. Simulation runs for 60 seconds by default.

## 💬 Support

For questions and support:
- Open an [Issue](https://github.com/aditichhteri/ros-code-checker-simulator/issues)
- Check the [Documentation](docs/)
- Contact: [GitHub Profile](https://github.com/aditichhteri)

## 🔑 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Acknowledgments

- Universal Robots for UR5 documentation and models
- ROS2 community for excellent tools and libraries
- Open Robotics for Gazebo simulator
- Contributors and testers

---

**Built with ❤️ for the ROS community**

*Last updated: December 2025*
